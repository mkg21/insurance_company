drop database if exists health_insurance;
create database health_insurance;

use health_insurance;

drop table if exists customer;
create table customer
(
	id int auto_increment,
    name varchar(20) not null,
    phone_number char(11) not null,
    address varchar(255) not null,
    primary key(id)
);
-- purch_plans_nums int --> view
-- total expenses
-- num_of_dependent --> view
-- insert into customer (c_name,phone_number,address) values('hossam','01215415615','cairo',1);
-- insert into customer (c_name,phone_number,address,ben_plan) values('ahmed','01215415615','cairo',2);


drop table if exists plan_type;
create table plan_type
(	
	id int auto_increment,
    type varchar(255) unique not null,
    price numeric(6,2) not null,
    primary key(id)
);

insert into plan_type(id , type,price) values(null , 'normal',1234.56);
insert into plan_type(id , type,price) values(null , 'premium',2134.56);
insert into plan_type(id , type,price) values(null , 'golden',4132.56);


drop table if exists purchased_plans;
create table purchased_plans
(
	id int auto_increment,
	customer_id int,
    ptype_id int ,
    primary key(id),
    foreign key(customer_id) references customer(id)
	on delete cascade
	on update cascade,
	foreign key(ptype_id) references plan_type(id)
	on delete set null
	on update cascade
);

-- insert into purchased_plans(customer_id,ptype_id) values(1,'premium');
-- insert into purchased_plans(customer_id,ptype_id) values(2,'golden');

alter table customer add 
(
	benplan_id int,	
	foreign key(benplan_id) references purchased_plans(id)
	on delete set null
	on update cascade
);

-- insert into customer (benplan_id) values(1);

drop table if exists dependant;
create table dependant
(
	id int auto_increment,
    name varchar(20) not null,
    customer_id int,
    benplan_id int,
    relationship varchar(20),
    birthdate date,
    primary key(id,customer_id) ,
    foreign key(customer_id) references customer(id)
    on delete cascade
    on update cascade,
     foreign key(benplan_id) references purchased_plans(id)
        on delete set null
		on update cascade
);

-- insert into dependant (d_name,customer_id,benplan_id,relationship,age) values('ahmed',1,1,'father',20);

drop table if exists hospital;
create table hospital
(
	id int auto_increment ,
    name varchar(255),
	address varchar(255) not null,
    primary key(id)
);

-- insert into hospital(hospital_name,address) values('elhorriya','cairo');
-- num_of_treated_people int --> view

drop table if exists insurance_claim;
create table insurance_claim
(
	id int auto_increment,
    expense_amount int,
    expense_details varchar(20),
    ins_date datetime,
    customer_id int,
    p_id int,
	ben_claim int, 
    -- solved bool
    primary key(id),
    foreign key(customer_id) references customer(id)
		on delete cascade
		on update cascade,
    foreign key(p_id) references purchased_plans(id)
        on delete set null
		on update cascade
);
-- check (claim = (select C.c_id from customer C,purchased_plans as PS where C.benplan_id=PS.p_id))
-- create view claim as select C.c_id from customer C,purchased_plans as PS where C.benplan_id=PS.p_id;
-- create view claim as select D.c_id from customer C,dependant D,purchased_plans as PS where C.c_id=D.customer_id and D.benplan_id=PS.p_id;

-- insert into insurance_claim (expense_amount,expense_details,ins_date,c_id,p_id,(claim)) values(5000,('heartattack','n'),12/10/2020,1,1,(claim));
-- insert into insurance_claim (expense_amount,expense_details,ins_date,c_id,p_id) values(5000,('heartattack','n'),12/10/2020,1,1);


drop table if exists has;
create table has
(
	plan_id int,
    Hosp_id int,
    foreign key (plan_id) references plan_type(id)
        on delete set null
		on update cascade,
	foreign key (Hosp_id) references hospital(id)
        on delete set null
		on update cascade
);

-- insert into has values (1,1);

drop table if exists provides;
create table provides
(
	H_id int,
    ins_id int,
    causeofTreat varchar(100),
    treats_period int,
    foreign key(H_id) references hospital(id)
    on delete set null
	on update cascade,
    foreign key(ins_id) references insurance_claim(id)
    on delete set null
	on update cascade
);








create view purch_plans_nums as select C.c_id,count(*) from customer C,purchased_plans PS where C.c_id=PS.customer_id;
create view num_of_dependent as select count(*) from customer C,dependant D where C.c_id=D.customer_id;
create view num_of_treated_people as select count(*) from
 customer C,dependant D,hospital H ,purchased_plans PS 
 where (C.benplan_id=PS.p_id) or (C.c_id=D.customer_id and D.benplan_id=PS.p_id) ;
 
 update insurance_claim IC set ben_claim = 
 (select distinct C.id from customer C,purchased_plans PS where IC.customer_id=C.id and C.benplan_id=PS.id );
 update insurance_claim IC set ben_claim = 
 (select distinct D.d_id from customer C,dependant D,purchased_plans PS where IC.c_id=C.c_id and C.c_id=D.customer_id and D.benplan_id=PS.p_id);
 
 
 
 -- my update 'galal'
create view list_of_customers as
	select * from customer;

select * from list_of_customers;

drop view if exists claims;
create view claims as
	select name , Ic.id , count(Ic.id) as nums 
    from customer c, insurance_claim Ic
    where c.id = Ic.customer_id;

select * from claims;

drop procedure if exists claim_detail;

DElIMITER //
create procedure claim_detail(
In calim_id int 
)
begin
	select * from insurance_claim where id=calim_id;
End //
DELIMITER ;

 

call claim_detail(1);



-- my update 'hosam'

create view list_of_plan_types as
select *
from plan_type;

drop procedure if exists get_customer_benefits;
DElIMITER //
create procedure get_customer_benefits(
In c_id int 
)
begin
	select benplan_id
    from customer 
    where id=c_id ;
End //
DELIMITER ;




drop procedure if exists dependants_of_customer;
DElIMITER //
create procedure dependants_of_customer(
In id int 
)
begin
	select dependant.id , name 
    from dependant 
    where dependant.customer_id=id and benplan_id is null
    ;
End //
DELIMITER ;



drop procedure if exists add_customer_benefits;
DElIMITER //
create procedure add_customer_benefits(
In c_id int ,
In plan_id int 
)
begin
	SET foreign_key_checks = 0;
	UPDATE customer
	SET benplan_id=plan_id
	WHERE id=c_id;
	SET foreign_key_checks = 1;
End //
DELIMITER ;


drop procedure if exists add_dependant_benefits;
DElIMITER //
create procedure add_dependant_benefits(
In d_id int ,
In plan_id int 
)
begin
	SET foreign_key_checks = 0;
	UPDATE dependant
	SET benplan_id=plan_id
	WHERE id=d_id;
	SET foreign_key_checks = 1;
End //
DELIMITER ;



call dependants_of_customer(1);
call get_customer_benefits(1);
