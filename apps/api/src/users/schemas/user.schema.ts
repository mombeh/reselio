import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { Role } from '../../auth/enums/role.enum';

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop()
  businessName: string;

  @Prop()
  phone: string;

  @Prop()
  address: string;

  @Prop()
  currency: string;

  @Prop({ default: Role.Customer, enum: Object.values(Role), type: String })
  role: Role;
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.virtual('userId').get(function () {
  return this._id;
});

UserSchema.set('toJSON', {
  virtuals: true,
  transform: (_doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    delete ret.password;
    return ret;
  },
});

UserSchema.set('toObject', {
  virtuals: true,
  transform: (_doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    delete ret.password;
    return ret;
  },
});
