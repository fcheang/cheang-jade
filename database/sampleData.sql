insert into employee (employeeSeq, lastName, firstName) values (1, 'Amy', 'Chan');

insert into employee (employeeSeq, lastName, firstName) values (2, 'Betty', 'Kwan');

insert into employee (employeeSeq, lastName, firstName) values (3, 'Cathy', 'Cheng');

insert into employeeView (employeeViewSeq, viewName) values (1, 'All Employee');

insert into location values ('Oakland');

insert into location values ('Union City');

insert into role values ('Manager');

insert into role values ('HR Manager');

insert into role values ('User');

insert into type values ('TS');

insert into user (userId, password, role, employeeViewSeq) values ('steve', 'steve', 'Manager', 1);

insert into user (userId, password, role, employeeViewSeq) values ('jeff', 'jeff', 'HR Manager', 1);

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 1, 'Oakland');

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 1, 'Union City');

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 2, 'Oakland');

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 2, 'Union City');

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 3, 'Oakland');

insert into viewMapping (employeeViewSeq, employeeSeq, location) values (1, 3, 'Union City');

insert into timesheet (employeeSeq, location, date, type, worked, overtime, vacation, sick, floating, holiday, other, comments, createdBy) values (1, 'Union City', '2009-1-1', 'TS', 8, 2, 0, 0, 0, 0, 0, 'Testing', 'steve');

insert into timesheet (employeeSeq, location, date, type, worked, overtime, vacation, sick, floating, holiday, other, comments, createdBy) values (2, 'Oakland', '2009-2-1', 'TS', 8, 2, 0, 0, 0, 0, 0, 'Testing2', 'steve');

insert into timesheet (employeeSeq, location, date, type, worked, overtime, vacation, sick, floating, holiday, other, comments, createdBy) values (2, 'Oakland', '2009-2-16', 'TS', 0, 0, 0, 0, 0, 0, 0, 'Testing3', 'jeff');