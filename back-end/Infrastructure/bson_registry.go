package infrastructure

import (
	"fmt"
	"reflect"

	"github.com/shopspring/decimal"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/bsoncodec"
	"go.mongodb.org/mongo-driver/bson/bsonrw"
	"go.mongodb.org/mongo-driver/bson/bsontype"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// DecimalCodec handles serialization and deserialization of decimal.Decimal for MongoDB
type DecimalCodec struct{}

// EncodeValue converts decimal.Decimal to primitive.Decimal128 for MongoDB storage.
func (dc *DecimalCodec) EncodeValue(ec bsoncodec.EncodeContext, vw bsonrw.ValueWriter, val reflect.Value) error {
	if !val.IsValid() || val.Type() != reflect.TypeOf(decimal.Decimal{}) {
		return bsoncodec.ValueEncoderError{Name: "DecimalCodec.EncodeValue", Types: []reflect.Type{reflect.TypeOf(decimal.Decimal{})}, Received: val}
	}
	d := val.Interface().(decimal.Decimal)

	d128, err := primitive.ParseDecimal128(d.String())
	if err != nil {
		return err
	}
	return vw.WriteDecimal128(d128)
}

// DecodeValue converts MongoDB types back into decimal.Decimal.
// It gracefully handles cases where old data was stored as an empty BSON document due to missing codecs.
func (dc *DecimalCodec) DecodeValue(dcx bsoncodec.DecodeContext, vr bsonrw.ValueReader, val reflect.Value) error {
	if !val.CanSet() || val.Type() != reflect.TypeOf(decimal.Decimal{}) {
		return bsoncodec.ValueDecoderError{Name: "DecimalCodec.DecodeValue", Types: []reflect.Type{reflect.TypeOf(decimal.Decimal{})}, Received: val}
	}

	switch vr.Type() {
	case bsontype.Decimal128:
		d128, err := vr.ReadDecimal128()
		if err != nil {
			return err
		}
		d, err := decimal.NewFromString(d128.String())
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(d))
	case bsontype.String:
		str, err := vr.ReadString()
		if err != nil {
			return err
		}
		d, err := decimal.NewFromString(str)
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(d))
	case bsontype.Double:
		f, err := vr.ReadDouble()
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(decimal.NewFromFloat(f)))
	case bsontype.Int32:
		i, err := vr.ReadInt32()
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(decimal.NewFromInt32(i)))
	case bsontype.Int64:
		i, err := vr.ReadInt64()
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(decimal.NewFromInt(i)))
	case bsontype.EmbeddedDocument:
		// Handle legacy data where decimal was serialized as an empty object '{}'
		err := vr.Skip()
		if err != nil {
			return err
		}
		val.Set(reflect.ValueOf(decimal.Zero))
	default:
		return fmt.Errorf("cannot decode %v into decimal.Decimal", vr.Type())
	}
	return nil
}

// NewMongoClientOptions creates MongoDB client options with the custom BSON registry for decimals configured.
func NewMongoClientOptions(uri string) *options.ClientOptions {
	// Register custom BSON codec for decimal.Decimal
	rb := bson.NewRegistryBuilder()
	bsoncodec.DefaultValueEncoders{}.RegisterDefaultEncoders(rb)
	bsoncodec.DefaultValueDecoders{}.RegisterDefaultDecoders(rb)

	decimalType := reflect.TypeOf(decimal.Decimal{})
	rb.RegisterTypeEncoder(decimalType, &DecimalCodec{})
	rb.RegisterTypeDecoder(decimalType, &DecimalCodec{})

	return options.Client().ApplyURI(uri).SetRegistry(rb.Build())
}
