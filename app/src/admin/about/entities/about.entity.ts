import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity('about')
export class About {
  @PrimaryColumn({ type: 'smallint', default: 1 })
  id: number = 1;
  @Column({ type: 'varchar', length: 255, nullable: true })
  facebook: string | null;
  @Column({ type: 'varchar', length: 255, nullable: true })
  instagram: string | null;
  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;
  @Column({ type: 'char', length: 9, nullable: true })
  phone: string | null;
  @Column({ name: 'place_description', type: 'text', nullable: true })
  placeDescription: string | null;
  @Column({
    name: 'place_address',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  placeAddress: string | null;
  @Column({
    name: 'place_address_link',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  placeAddressLink: string | null;

  @Column({ name: 'delivery_on', type: 'boolean', default: false })
  deliveryOn: boolean;
}
