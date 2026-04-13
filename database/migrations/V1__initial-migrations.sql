
--TODO:  tables for personnel and they permissions
CREATE DATABASE IF NOT EXISTS burger_delivery;

USE burger_delivery;

-- create table roles
CREATE TABLE IF NOT EXISTS roles (
  Id VARCHAR(20) PRIMARY KEY,
  display_name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(150)
);

-- comments for table roles
COMMENT ON TABLE roles IS 'Storage table for roles of personnel.';
COMMENT ON COLUMN roles.id IS 'Unique role id (for example, "admin", "employee", "manager", "owner").';
COMMENT ON COLUMN roles.display_name IS 'Display role name for user interface.';
COMMENT ON COLUMN roles.description IS 'description about role.';


-- create table permisions
CREATE TABLE IF NOT EXISTS permits (
  id VARCHAR(50) PRIMARY KEY, -- Unique permit name (for example, "products:read", "users:manage")
  display_name VARCHAR(50) NOT NULL,
  description VARCHAR(150) 
);

-- comments for table permits
COMMENT ON TABLE permits IS 'Storage table for permits of personnel.';
COMMENT ON COLUMN permits.id IS 'Unique name of permit (for example, "products:read").';
COMMENT ON COLUMN permits.display_name IS 'dsplay name for user interface.';
COMMENT ON COLUMN permits.description IS 'explain why this permit you need.';

CREATE TABLE IF NOT EXISTS permit_in_role (
  role_id VARCHAR(20) NOT NULL,
  permit_id VARCHAR(50) NOT NULL,

  PRIMARY KEY (role_id, permit_id),

  CONSTRAINT fk_role
    FOREIGN KEY (role_id)
    REFERENCES roles (id)
    ON DELETE CASCADE ON UPDATE CASCADE, 

  CONSTRAINT fk_permit
    FOREIGN KEY (permit_id)
    REFERENCES permits (id)
    ON DELETE CASCADE ON UPDATE CASCADE 

);

-- Cmments for table permit_in_role
COMMENT ON TABLE permit_in_role IS 'Таблиця зв''язку, що визначає, які дозволи належать до яких ролей.';
COMMENT ON COLUMN permit_in_role.role_id IS 'Ідентифікатор ролі, зовнішній ключ до таблиці roles.';
COMMENT ON COLUMN permit_in_role.permit_id IS 'Ідентифікатор дозволу, зовнішній ключ до таблиці permits.';

CREATE TABLE IF NOT EXISTS passwords(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  password CHAR(60) NOT NULL,
  salt CHAR(29) NOT NULL
);

-- Create table persons
CREATE TABLE IF NOT EXISTS personnel (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  password_id UUID NOT NULL REFERENCES passwords (id),
  enc_phone VARCHAR(255),
  enc_name VARCHAR(255),
  enc_surname VARCHAR(255),
  enc_father_name VARCHAR(255),
  birthday DATE,
  enc_address VARCHAR(255),
  picture VARCHAR(255), -- url on picture
  role_id VARCHAR(20) REFERENCES roles (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS one_owner_per_role  
ON personnel (role_id)
WHERE role_id = 'owner';

COMMENT ON TABLE personnel IS 'Storage info about personnel of restorant.';
COMMENT on COLUMN personnel.role_id IS 'role off user for permits';

-- TODO: table for restorant
-- create table about
CREATE TABLE IF NOT EXISTS about (
 id SMALLINT PRIMARY KEY DEFAULT 1,
  facebook VARCHAR(255),
  instagram VARCHAR(255),
  email VARCHAR(255),
  phone CHAR(9), --phone suport only ukrainian numbers +380 66 73 45 027 +380 3477 25053 
                  -- in format 667345027 (+380) is defoult and we add in in api
  place_address VARCHAR(255), 
  place_address_link VARCHAR(255),
  place_description TEXT -- description about our delyvery why we the best
);
-- Коментарі для таблиці about
COMMENT ON TABLE about IS 'Table for storage general information about our restoran.';
COMMENT ON COLUMN about.id IS 'Uniq id is 1 because is only one row.';
COMMENT ON COLUMN about.facebook IS 'URL-addres our page in Facebook.';
COMMENT ON COLUMN about.instagram IS 'URL-addres our page in Instagram.';
COMMENT ON COLUMN about.email IS 'Our email adress.';
COMMENT ON COLUMN about.phone IS 'Phne number to contact us.';
COMMENT ON COLUMN about.place_description IS 'detailed company description.';

-- TODO:


CREATE TABLE IF NOT EXISTS opening_hours (
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6) PRIMARY KEY,
  opens_at TIME WITHOUT TIME ZONE,
  closes_at TIME WITHOUT TIME ZONE
);

CREATE TABLE IF NOT EXISTS brake_times_by_date (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_date DATE NOT NULL,
  closes_at TIME WITHOUT TIME ZONE NOT NULL,
  opens_at TIME WITHOUT TIME ZONE NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_brake_times_by_date_date ON brake_times_by_date (work_date); 
--TODO:

CREATE TABLE IF NOT EXISTS drinks(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE,
  price DECIMAL(5, 2) NOT NULL,
  calories SMALLINT NOT NULL,
  description TEXT
);

COMMENT ON TABLE drinks IS 'there is drinks we can chose for menu';
COMMENT ON COLUMN drinks.calories IS 'approximate number of calories in one drink';
COMMENT ON COLUMN drinks.price IS 'Max price is 999.99';

CREATE TABLE IF NOT EXISTS dishes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  price DECIMAL(5, 2) NOT NULL,
  name VARCHAR(255) NOT NULL UNIQUE
);

COMMENT ON TABLE dishes IS 'there is dishes we can chse for menu';

  CREATE TABLE IF NOT EXISTS menu (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL ,
    subtitle VARCHAR(255) NOT NULL DEFAULT '',
    price DECIMAL(6,2) NOT NULL,
    onboard BOOLEAN NOT NULL,
    image_small VARCHAR(255),
    image_medium VARCHAR(255),
    description TEXT,
    rating DECIMAL(3,2),
    calories SMALLINT,

    CONSTRAINT menu_title_subtitle_name
    UNIQUE (title, subtitle)
  );

CREATE INDEX IF NOT EXISTS idx_menu_oboard ON menu (onboard);

COMMENT ON TABLE menu IS 'there you can comdine dishes and drinks to some menu positions';
COMMENT ON COLUMN menu.price IS 'max price is 9999.99';
COMMENT ON COLUMN menu.onboard IS 'if this position is available';
COMMENT ON COLUMN menu.image_small IS 'URL to picture for cards';
COMMENT ON COLUMN menu.image_medium IS 'URL to picture for open cards';
COMMENT ON COLUMN menu.rating IS 'rating is with stars from 1.00 to 5.00';
COMMENT ON COLUMN menu.calories IS 'count of calories, that is for future feature';

CREATE TABLE IF NOT EXISTS drinks_in_menu (
  drink_id UUID NOT NULL,
  menu_id UUID NOT NULL,
  PRIMARY KEY (drink_id, menu_id),
  
  CONSTRAINT fk_drink
  FOREIGN KEY (drink_id)
  REFERENCES drinks (id)
  ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_menu 
  FOREIGN KEY (menu_id)
  REFERENCES menu (id)
  ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE drinks_in_menu IS 'table for references which drink in which menu position';

CREATE TABLE IF NOT EXISTS dishes_in_menu (
  dish_id UUID NOT NULL,
  menu_id UUID NOT NULL,
  PRIMARY KEY (dish_id, menu_id),
  
  CONSTRAINT fk_dish
  FOREIGN KEY (dish_id)
  REFERENCES dishes (id)
  ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_menu
  FOREIGN KEY (menu_id)
  REFERENCES menu (id)
  ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE dishes_in_menu IS 'table for references, with dish in wich menu position';

CREATE TABLE IF NOT EXISTS categories (
  id VARCHAR(20) PRIMARY KEY,
  display_name VARCHAR(25) NOT NULL,
  description TEXT
);

COMMENT ON TABLE categories IS 'categories for filter menu';
COMMENT on COLUMN categories.Id IS 'id is string like "drink", "vegeterian" or "spicy"';


CREATE TABLE IF NOT EXISTS menu_in_category (
  category_id VARCHAR(20) NOT NULL,
  menu_id UUID NOT NULL,
  PRIMARY KEY (category_id, menu_id),

  CONSTRAINT fk_category
  FOREIGN KEY (category_id)
  REFERENCES categories (id)
  ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_menu
  FOREIGN KEY (menu_id)
  REFERENCES menu (id)
  ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE menu_in_category IS 'this table explain wich dish in which category';


-- TODO: sessions

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  personnel_id UUID NOT NULL REFERENCES personnel (id) ON DELETE CASCADE ON UPDATE CASCADE,
  sas CHAR(32) NOT NULL,
  srs CHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
 
);
CREATE INDEX IF NOT EXISTS idx_sessions_sas_srs ON sessions (sas, srs);

-- TODO: orders

CREATE TYPE IF NOT EXISTS payment_method AS ENUM (
    'CARD_ONLINE',       -- Оплата банківською карткою онлайн
    'CARD_ON_DELIVERY',  -- Оплата карткою при отриманні (через POS-термінал)
    'CASH_ON_DELIVERY',  -- Оплата готівкою при отриманні
    'BANK_TRANSFER',     -- Банківський переказ (для корпоративних клієнтів)
    'PAYPAL',            -- PayPal або інші сторонні платіжні системи
    'APPLE_PAY',         -- Apple Pay / Google Pay
    'GIFT_CARD'          -- Подарункова картка
);

CREATE TYPE IF NOT EXISTS order_status AS ENUM (
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
);



CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    payment payment_method NOT NULL,
    amount DECIMAL(7,2) NOT NULL,
    enc_phone VARCHAR(255) NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    delivery BOOLEAN NOT NULL,
    delivery_price DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    street VARCHAR(100),
    status order_status NOT NULL DEFAULT 'pending',
    enc_address_full VARCHAR(255),
    enc_address_clarification VARCHAR(255),
    description TEXT,
    enc_email VARCHAR(255) DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_orders_create_at ON orders (created_at)
USING HASH WITH BUCKET_COUNT = 8;

CREATE INDEX IF NOT EXISTS idx_orders_status_created_at
ON orders (status, created_at DESC);

CREATE TABLE IF NOT EXISTS customer_order_phone_hashes (
hash_phone CHAR(31) NOT NULL,
order_id UUID NOT NULL,
PRIMARY KEY (hash_phone, order_id),

    CONSTRAINT fk_order
    FOREIGN KEY (order_id)
    REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);




-- TODO: dish in order

CREATE TABLE IF NOT EXISTS menu_item_in_order (
    order_id UUID NOT NULL, 
    menu_id UUID NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (order_id, menu_id),

    CONSTRAINT fk_order
    FOREIGN KEY (order_id)
    REFERENCES orders (id)
    ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_menu
    FOREIGN KEY (menu_id)
    REFERENCES menu (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_menuItem_in_order_time ON menu_item_in_order (created_at)
USING HASH WITH BUCKET_COUNT = 8;


CREATE TABLE IF NOT EXISTS delivery_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  distance SMALLINT NOT NULL,
  min_order SMALLINT NOT NULL,
  delivery_price DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  onboard BOOLEAN DEFAULT true
);

CREATE UNIQUE INDEX IF NOT EXISTS delivery_prices_unique_rate
ON delivery_prices (distance, min_order);


-- TODO: allergens

-- TODO: allergen in drink

-- TODO: ingredients

-- TODO: allergen in ingredient

-- TODO: ingredient in dish

-- TODO: discount

-- TODO: ............... NEXT WILL BE  IN SOME ANOTHER WAY

-- TODO: data add with CLI

INSERT INTO roles (id, display_name, description)
VALUES 
('owner', 'власник', 'Максимальний доступ до усіх налаштувань включає в себе усі дозволи.'),
('admin', 'адміністратор', 'можливість надавати тимчасово більшу кількісь повноважень для розробників'),
('manager', 'менеджер', NULL),
('employee', 'працівник', NULL)
ON CONFLICT (id) DO NOTHING; 

-- TODO: insert some permissions
INSERT INTO permits (id, display_name, description)
VALUES
('personnel:add', 'Додати користовача', 'можливість додавати нових користовачів в таблицю personnel'),
('personnel:role', 'Оновлення ролі', 'можливість оновлювати ролі користувачів'),
('personnel:info', 'інформація про одного працівника', NULL),
('personnel:get-all', 'список усіх працівників', NULL),
('personnel:delete', 'видалити працівника', NULL),
('permits:info', 'інформація про перміт', NULL),
('permits:get-all', 'список пермітів', NULL),
('roles:operations', 'операції з ролями', 'поки що охоплює усі операції з ролями'),
('about:get', 'опис закладу', NULL),
('about:update', 'оновлення опису', NULL),
('drink:add', 'Додати напій', NULL),
('drink:update', 'Оновити ціну напою', NULL),
('drink:delete', 'Видалити напій', NULL),
('dish:add', 'Додати страву', NULL),
('dish:update', 'Оновити страву', NULL),
('dish:delete', 'Видалити страву', NULL),
('category:add', 'Додати категорію', NULL),
('category:update', 'Оновити категорію', NULL),
('category:delete', 'Видалити категорію', NULL),
('manager:info', 'Оновити менеджера', 'Можливість оновити персональні дані працівника з дозволом "manager"'),
('employee:add', 'Додати працівника', 'Можливість додати працівника з дозволом "employee"'),
('employee:info', 'Оновити працівника', 'Можливість оновити персональні дані працівника з дозволом "employee"'),
('employee:delete', 'Видалити працівника', 'Можливість видалити працівника з дозволом "employee"'),
('menu:add', 'Додати позицію', 'Можливість додати в меню'),
('menu:delete', 'Видалити позицію ', 'Можливість видалити з меню'),
('menu:update', 'Оновити позицію', 'Можливість оновити інформацію про позицію меню'),
('menu:onboard', 'Статус позиції', 'Можливість змінити статус наявності позиції меню'),
('order:read', 'отримувати замовлення', NULL),
('order:update-status', 'оновлювати статус замовлення', NULL),
('order:cancle', 'Відмінити замовлення', NULL),
('opening:read', 'Перевірити час відкриття', NULL),
('opening:update', 'оновлювати час відкриття', NULL),
('delivery-price:read', 'отримати ціни на доставку', NULL),
('delivery-price:delete', 'видалити зону доставки', NULL),
('delivery-price:add', 'додати зону доставки', NULL)
ON CONFLICT (id) DO NOTHING; 


-- 1. add all permits to owner
INSERT INTO permit_in_role (role_id, permit_id)
SELECT 'owner', id FROM permits
ON CONFLICT (role_id, permit_id) DO NOTHING;

-- 2. add permits to manager
INSERT INTO permit_in_role (role_id, permit_id)
SELECT 'manager', id FROM permits
WHERE id LIKE 'menu:%' OR id LIKE 'drink:%' OR id LIKE 'dish:%' OR id LIKE 'employee:%' OR id='manager:info'
ON CONFLICT (role_id, permit_id) DO NOTHING;

-- 3. add permit onboard to 'employee'
INSERT INTO permit_in_role (role_id, permit_id)
VALUES 
('employee', 'menu:onboard'),
('employee', 'employee:info')
ON CONFLICT (role_id, permit_id) DO NOTHING;

INSERT INTO opening_hours (day_of_week, opens_at, closes_at)
VALUES
(0,null,null),
(1,null,null),
(2,null,null),
(3,null,null),
(4,null,null),
(5,null,null),
(6,null,null)
ON CONFLICT (day_of_week) DO NOTHING;

-- TODO: add default categories
INSERT INTO categories(id, display_name, description)
VALUES 
('drink', 'Напої', ''),
('dessert', 'Десерти', ''),
('vegeterian', 'Для вегетеріанців', 'Страви які підійдуть вегетеріанцям'),
('burger', 'Бургери', ''),
('salat', 'Салати', ''),
('fried', 'Смажене', 'все що з фретюру'),
('snack', 'Снеки', 'якісь смаколики'),
('kombomenu', 'Комбо-меню', ''),
('souse', 'Соуси', ''),
('special', 'Спеціальні пропозиції', ''),
('spicy', 'Гостре', 'для тих хто любить гостре'),
('helthy', 'Здорова Їжа', 'те що міг би дозволити лікар')
ON CONFLICT DO NOTHING;

INSERT INTO delivery_prices (min_order, delivery_price, distance)
VALUES 
(150, 50.00, 2000),
(200, 25.00, 2000),
(150, 75.00, 2500),
(200, 50.00, 2500),
(250, 25.00, 2500),
(150, 100.00, 3500),
(200, 75.00, 3500),
(250, 50.00, 3500),
(350, 25.00, 3500),
(250, 100.00, 4000),
(350, 50.00, 4000),
(400, 25.00, 4000)
ON CONFLICT DO NOTHING;