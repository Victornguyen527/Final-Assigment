--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: VNguyen
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, and stored procedures
-- Change Log: When,Who,What
-- 2026-03-14,RRoot,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_VNguyen')
	 Begin 
	  Alter Database [ITFnd130FinalDB_VNguyen] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_VNguyen;
	 End
	Create Database ITFnd130FinalDB_VNguyen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_VNguyen;

-- Create Tables (Review Module 01)-- 

create table Courses
	(CourseID int identity(1,1) not null
	,CourseName nvarchar(100) not null
	,CourseStartDate date null 
	,CourseEndDate date null 
	,CourseStartTime time(0) null 
	,CourseEndTime time(0) null 
	,CourseDaysOfWeek nvarchar(1) null 
	,CourseCurrentPrice money null)
go


create table Students 
	(StudentID int identity(1,1) not null
	,StudentFirstName nvarchar(100) not null
	,StudentLastName nvarchar(100) not null
	,StudentNumber nvarchar(100) not null
	,StudentEmail nvarchar(100) not null
	,PhoneNumber nvarchar(15) not null
	,StreetAddress nvarchar(100) not null
	,City nvarchar(100) not null
	,StateCode nvarchar(2) not null
	,ZipCode nvarchar(10) not null)
go

create table Enrollments
	(EnrollmentID int identity(1,1) not null
	,CourseID int not null
	,StudentID int not null
	,SignUpDate date not null
	,AmountPaid money not null)
go

-- Add Constraints (Review Module 02) -- 
-- Type = Primary and Foreign Key

alter table Courses
	add constraint pkCourses primary key (CourseID);

alter table Students
	add constraint pkStudents primary key (StudentID);

alter table Enrollments
	add constraint pkEnrollments primary key (EnrollmentID);

alter table Enrollments
	add constraint fkEnrollmentsCourses foreign key (CourseID) references Courses(CourseID);

alter table Enrollments
	add constraint fkEnrollmentsStudents foreign key (StudentID) references Students(StudentID);

-- Type = Unique

alter table Courses
	add constraint uCourseName unique (CourseName);

alter table Students
	add constraint uStudentNumber unique (StudentNumber);

alter table Students
	add constraint uStudentEmail unique (StudentEmail);

-- Type = Default

alter table Enrollments
	add constraint dAmountPaid default 0 for AmountPaid;


-- Type = Check

alter table Courses
	add constraint ckDateStartBeforeEnd check (CourseStartDate < CourseEndDate);

alter table Courses
	add constraint ckDateEndAfterStart check (CourseEndDate > CourseStartDate);

alter table Courses
	add constraint ckTimeStartBeforeEnd check (CourseStartTime < CourseEndTime);

alter table Courses
	add constraint ckTimeEndAfterStart check (CourseEndTime > CourseStartTime);

alter table Courses
	add constraint ckCourseCurrentPriceZeroOrMore check (CourseCurrentPrice>=0);

alter table Students
	add constraint ckStudentEmail check (StudentEmail like '%_@%_.%_');

alter table Students
	add constraint ckPhoneNumber check (PhoneNumber like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

alter table Students
	add constraint ckZipCode check (ZipCode like '[0-9][0-9][0-9][0-9][0-9]%' 
	or ZipCode like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
go

-- Add Views (Review Module 03 and 06) -- 

create view vCourses
	with schemabinding 
	as select 
	CourseID
	,CourseName
	,CourseStartDate
	,CourseEndDate
	,CourseStartTime
	,CourseEndTime
	,CourseDaysOfWeek
	,CourseCurrentPrice
	from dbo.Courses
go

create view vStudents 
	with schemabinding 
	as select 
	StudentID
	,StudentFirstName
	,StudentLastName
	,StudentNumber
	,StudentEmail
	,'(' + left(PhoneNumber,3) + ')-' + stuff(right(PhoneNumber,7),4,0,'-') as Phone
	,StreetAddress
	,City
	,StateCode
	,ZipCode
	from dbo.Students
 go

create view vEnrollments 
	with schemabinding 
	as select 
	EnrollmentID
	,CourseID
	,StudentID
	,SignUpDate
	,AmountPaid
	from dbo.Enrollments
 go

 create view vFullTable
	with schemabinding
	as select
	C.CourseName as Course
	,format(C.CourseStartDate, 'M/dd/yyyy') + ' to ' + format(C.CourseEndDate, 'M/d/yyyy') as Dates
	,C.CourseDaysOfWeek as [Days]
	,C.CourseStartTime as [Start]
	,C.CourseEndTime as [End]
	,C.CourseCurrentPrice as Price
	,S.StudentFirstName + ' ' + S.StudentLastName as Student
	,S.StudentNumber as Number
	,S.StudentEmail as Email
	,'(' + left(S.PhoneNumber,3) + ')-' + stuff(right(S.PhoneNumber,7),4,0,'-') as Phone
	,S.StreetAddress + S.City + S.StateCode + S.ZipCode as [Address]
	,E.SignUpDate as SignupDate
	,E.AmountPaid as Paid
	from dbo.vCourses as C 
	join dbo.Enrollments as E 
	on C.CourseID = E.CourseID 
	join dbo.Students as S 
	on S.StudentID = E.StudentID
go



--< Test Tables by adding Sample Data >--  
begin try
	begin transaction
		insert into Courses (CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
		values
		('SQL1 - Winter 2017','2017-01-10','2017-01-24','06:00:00','08:50:00','T',399),
		('SQL2 - Winter 2017','2017-01-31','2017-02-14','06:00:00','08:50:00','T',399)
	commit transaction
end try
begin catch
	rollback transaction
	print error_message()
end catch
go

begin try
	begin transaction
		insert into Students (StudentFirstName, StudentLastName, StudentNumber, StudentEmail, PhoneNumber, StreetAddress, City, StateCode, ZipCode)
		values
		('Bob','Smith','B-Smith-071','Bsmith@HipMail.com','2061112222','123 Main St.','Seattle','WA','98001'),
		('Sue','Jones','S-Jones-003','SueJones@YaYou.com','2062314321','333 1st Ave.','Seattle','WA','98001')
	commit transaction
end try
begin catch
	rollback transaction
	print error_message()
end catch
go

begin try
	begin transaction
		insert into Enrollments (CourseID, StudentID, SignUpDate, AmountPaid)
		values
		(1,1,'2017-01-03',399)
		,(1,2,'2016-12-14',349)
		,(2,1,'2017-01-12',399)
		,(2,2,'2016-12-14',349)
	commit transaction
end try
begin catch
	rollback transaction
	print error_message()
end catch
go
-- Add Stored Procedures (Review Module 04 and 08) --

-- Three for each table Insert, Update, and Delete

/*

create proc
	as
	begin 
		declare @RC int = 0;
		begin try												I made this sproc template based on the demo in module 08
			begin transaction									I will use this to make my insert update and delete sprocs

			commit transaction
			set @RC = +1
		end try

		begin catch
			print Error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

*/

-- Insert Courses sproc
create proc pInsertCourses
	(@CourseName nvarchar(100)					-- this section is copy pasted from the create tables code but with an added @ in front
	,@CourseStartDate date
	,@CourseEndDate date
	,@CourseStartTime time(0)
	,@CourseEndTime time(0)
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice money)
	as
	begin 
		declare @RC int = 0;
		begin try												
			begin transaction									
				insert into Courses (CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
					values (@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseDaysOfWeek, @CourseCurrentPrice)
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Update Courses sproc
create proc pUpdateCourses
	(@CourseID int
	,@CourseName nvarchar(100)				
	,@CourseStartDate date
	,@CourseEndDate date
	,@CourseStartTime time(0)
	,@CourseEndTime time(0)
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice money)
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				update Courses
					set CourseName = @CourseName										-- it got too confusing for me to have show your work blocks of code but I figured out when trying to test my sprocs that reversing the @ such as
						,CourseStartDate = @CourseStartDate								-- @CourseName = CourseName instead of CourseName = @CourseName causes the sproc test to fail to show error
						,CourseEndDate = @CourseEndDate
						,CourseStartTime = @CourseStartTime
						,CourseEndTime = @CourseEndTime
						,CourseDaysOfWeek = @CourseDaysOfWeek
						,CourseCurrentPrice = @CourseCurrentPrice
					where CourseID = CourseID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Delete Courses sproc
create proc pDeleteCourses
	(@CourseID int)
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				delete
					from Courses
					where CourseID = @CourseID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Insert Students sproc
create proc pInsertStudents
	(@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentNumber nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@PhoneNumber nvarchar(15)
	,@StreetAddress nvarchar(100)
	,@City nvarchar(100)
	,@StateCode nvarchar(2)
	,@ZipCode nvarchar(10))
	as
	begin 
		declare @RC int = 0;
		begin try												
			begin transaction									
				insert into Students (StudentFirstName, StudentLastName, StudentNumber, StudentEmail, PhoneNumber, StreetAddress, City, StateCode, ZipCode)
					values (@StudentFirstName, @StudentLastName, @StudentNumber, @StudentEmail, @PhoneNumber, @StreetAddress, @City, @StateCode, @ZipCode)
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Update Students sproc
create proc pUpdateStudents
	(@StudentID int
	,@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentNumber nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@PhoneNumber nvarchar(15)
	,@StreetAddress nvarchar(100)
	,@City nvarchar(100)
	,@StateCode nvarchar(2)
	,@ZipCode nvarchar(10))
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				update Students
					set StudentFirstName = @StudentFirstName
						,StudentLastName = @StudentLastName
						,StudentNumber = @StudentNumber
						,StudentEmail = @StudentEmail
						,PhoneNumber = @PhoneNumber
						,StreetAddress = @StreetAddress
						,City = @City
						,StateCode = @StateCode
						,ZipCode = @ZipCode
					where StudentID = @StudentID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Delete Students sproc
create proc pDeleteStudents
	(@StudentID int)
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				delete
					from Students
					where StudentID = @StudentID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Insert Enrollments sproc
create proc pInsertEnrollments
	(@CourseID int
	,@StudentID int
	,@SignUpDate date
	,@AmountPaid money)
	as
	begin 
		declare @RC int = 0;
		begin try												
			begin transaction									
				insert into Enrollments (CourseID, StudentID, SignUpDate, AmountPaid)
					values (@CourseID, @StudentID, @SignUpDate, @AmountPaid)
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Update Enrollments sproc
create proc pUpdateEnrollments
	(@EnrollmentID int
	,@CourseID int
	,@StudentID int
	,@SignUpDate date
	,@AmountPaid money)
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				update Enrollments
					set CourseID = @CourseID
						,StudentID = @StudentID
						,SignUpDate = @SignUpDate
						,AmountPaid = @AmountPaid
					where EnrollmentID = @EnrollmentID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Delete Enrollments sproc
create proc pDeleteEnrollments
	(@EnrollmentID int)
	as
	begin 
		declare @RC int = 0;
		begin try
			begin transaction
				delete
					from Enrollments
					where EnrollmentID = @EnrollmentID;
			commit transaction
			set @RC = +1
		end try

		begin catch
			print error_Number()
			print error_message()
			set @RC = -1
			rollback transaction
		end catch
	return @RC;
	end
go

-- Set Permissions --

deny select, insert, update, delete on Courses to public;
deny select, insert, update, delete on Students to public;
deny select, insert, update, delete on Enrollments to public;

grant select on vCourses to public;
grant select on vStudents to public;
grant select on vEnrollments to public;
grant select on vFullTable to public;

grant execute on pInsertCourses to public;
grant execute on pUpdateCourses to public;
grant execute on pDeleteCourses to public;

grant execute on pInsertStudents to public;
grant execute on pUpdateStudents to public;
grant execute on pDeleteStudents to public;

grant execute on pInsertEnrollments to public;
grant execute on pUpdateEnrollments to public;
grant execute on pDeleteEnrollments to public;

--< Test Sprocs >-- 

/*																	I made this sproc test template using demo from module 08
declare @Status int;
execute @Status = [SPROC NAME]
select case @Status
	when +1 then '[SPROC TYPE] was successful!'
	when -1 then '[SPROC TYPE] failed!'
end as [Status]
select * from v[NAME] where [ID] = @@IDENTITY
*/


-- Test of Insert, Update, and Delete sprocs for Courses
declare @Status int;
execute @Status = pInsertCourses
				@CourseName = 'TST'
				,@CourseStartDate = '2026-03-20'
				,@CourseEndDate = '2026-03-21'
				,@CourseStartTime = '06:00:00'
				,@CourseEndTime = '08:30:00'
				,@CourseDaysOfWeek = 'F'
				,@CourseCurrentPrice = 300
select case @Status
	when +1 then 'Insert was successful!'
	when -1 then 'Insert failed!'
end as [Status]
select * from vCourses where CourseID = @@IDENTITY
go

declare @Status int;
execute @Status = pUpdateCourses
				@CourseID = @@IDENTITY
				,@CourseName = 'SQL1 - Winter 2017'				-- this will cause a fail for update because of duplicate course name				
				,@CourseStartDate = '2026-03-12'
				,@CourseEndDate = '2026-03-21'
				,@CourseStartTime = '06:00:00'
				,@CourseEndTime = '08:10:00'
				,@CourseDaysOfWeek = 'M'
				,@CourseCurrentPrice = 600
select case @Status
	when +1 then 'Update was successful!'
	when -1 then 'Update failed!'
end as [Status]
select * from vCourses where CourseID = @@IDENTITY
go

declare @Status int;
execute @Status = pDeleteCourses
					@CourseID = @@IDENTITY
select case @Status
	when +1 then 'Delete was successful!'
	when -1 then 'Delete failed!'
end as [Status]
select * from vCourses where CourseID = @@IDENTITY
go

-- Test of Insert, Update, and Delete sprocs for Students
declare @Status int;
execute @Status = pInsertStudents
				@StudentFirstName = 'Nguyen'
				,@StudentLastName = 'Nguyen'
				,@StudentNumber = 'N-Nguyen002'
				,@StudentEmail = 'NNguyen@YeeHaw.com'
				,@PhoneNumber = '2533077004'
				,@StreetAddress = '303 3rd St.'
				,@City = 'Seattle'
				,@StateCode = 'OR'
				,@ZipCode = '98409'
select case @Status
	when +1 then 'Insert was successful!'
	when -1 then 'Insert failed!'
end as [Status]
select * from vStudents where StudentID = @@IDENTITY
go

declare @Status int;
execute @Status = pUpdateStudents
				@StudentID = @@IDENTITY
				,@StudentFirstName = 'Victor'
				,@StudentLastName = 'Nguyen'
				,@StudentNumber = 'V-Nguyen002'
				,@StudentEmail = 'SueJones@YaYou.com'							-- this will cause fail for update as it is a duplicate email
				,@PhoneNumber = '2533047004'
				,@StreetAddress = '303 2nd St.'
				,@City = 'Tacoma'
				,@StateCode = 'WA'
				,@ZipCode = '98409'
select case @Status
	when +1 then 'Update was successful!'
	when -1 then 'Update failed!'
end as [Status]
select * from vStudents where StudentID = @@IDENTITY
go

declare @Status int;
execute @Status = pDeleteStudents
					@StudentID = @@IDENTITY
select case @Status
	when +1 then 'Delete was successful!'
	when -1 then 'Delete failed!'
end as [Status]
select * from vStudents where StudentID = @@IDENTITY
go


-- Test of Insert, Update, and Delete sprocs for Enrollments
declare @Status int;																-- I'm inserting this again to test insert enrollment sproc
execute @Status = pInsertStudents
				@StudentFirstName = 'Nguyen'
				,@StudentLastName = 'Nguyen'
				,@StudentNumber = 'N-Nguyen002'
				,@StudentEmail = 'NNguyen@YeeHaw.com'
				,@PhoneNumber = '2533077004'
				,@StreetAddress = '303 3rd St.'
				,@City = 'Seattle'
				,@StateCode = 'OR'
				,@ZipCode = '98409'
select case @Status
	when +1 then 'Insert was successful!'
	when -1 then 'Insert failed!'
end as [Status]
select * from vStudents where StudentID = @@IDENTITY
go

declare @Status int;
execute @Status = pInsertEnrollments
				@CourseID = 2
				,@StudentID = 4
				,@SignUpDate = '2026-03-21'
				,@AmountPaid = 200
select case @Status
	when +1 then 'Insert was successful!'
	when -1 then 'Insert failed!'
end as [Status]
select * from vEnrollments where EnrollmentID = @@IDENTITY
go

declare @Status int;
execute @Status = pUpdateEnrollments
				@EnrollmentID = @@IDENTITY
				,@CourseID = 2
				,@StudentID = 4
				,@SignUpDate = '2026-03-12'
				,@AmountPaid = 400
select case @Status
	when +1 then 'Update was successful!'
	when -1 then 'Update failed!'
end as [Status]
select * from vEnrollments where EnrollmentID = @@IDENTITY
go

declare @Status int;
execute @Status = pDeleteEnrollments
					@EnrollmentID = @@IDENTITY
select case @Status
	when +1 then 'Delete was successful!'
	when -1 then 'Delete failed!'
end as [Status]
select * from vEnrollments where EnrollmentID = @@IDENTITY
go



select * from vCourses
select * from vStudents
select * from vEnrollments
select * from vFullTable

-- Important: Your entire script must run without highlighting individual statements!  
/**************************************************************************************************/