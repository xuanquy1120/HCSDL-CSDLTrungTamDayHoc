-------Function----------
-----S? l?p có trong ngày th? ()----------
Create function dsLopHoc (@ngayhoc nvarchar(10))
Returns int 
as begin
	Declare @SoLop int
	select @SoLop = COUNT (TTLopHoc.IDLH)
	from TTLopHoc,TimeLopHoc
	where NgayHoc = @ngayhoc AND TTLopHoc.IDLH = TimeLopHoc.IDLH
	Return @SoLop
	end
--exec function
Select  dbo.dsLopHoc(N'Th? 4') as N'S? L?p Trong Ngày'
---------View----------
Create view NhieuLop
as  
	select TTLopHoc.IDLH , TenLop ,TimeStart , TimeEnd, NgayHoc ,MonHoc.IDMH, TenMonHoc , KhoiMonHoc
	from TTLopHoc,TimeLopHoc,MonHoc
	where TTLopHoc.IDLH = TimeLopHoc.IDLH 
		  AND  TimeStart = '10' AND TimeEnd = '12' AND NgayHoc = N'Th? 4'
	      AND TTLopHoc.IDMH = MonHoc.IDMH 
--exec view
select distinct * from NhieuLop
----------Proc-----------
Create Proc LopKemNhat
@IDMH char(5),@Khoi char(5) , 
@maxDiem float output , @TenLop nvarchar(30) output , @IDLH char(5) output
As begin
	
	select @maxDiem = MIN(Diem)
	from Diem,MonHoc,HocVien
	where Diem.IDMH = MonHoc.IDMH AND MonHoc.IDMH = @IDMH 
		AND MonHoc.IDMH = Diem.IDMH And @Khoi = KhoiMonHoc
	
	select @TenLop = TTLopHoc.TenLop 
	from TTLopHoc,HocVien,Diem 
	where TTLopHoc.IDLH = HocVien.IDLH AND HocVien.IDHV = Diem.IDHV
		 AND Diem.Diem = @maxDiem AND Diem.IDMH = @IDMH
		 
	select @IDLH = TTLopHoc.IDLH 
	from TTLopHoc,HocVien,Diem
	where TTLopHoc.IDLH = HocVien.IDLH AND HocVien.IDHV = Diem.IDHV
		 AND Diem.Diem = @maxDiem AND Diem.IDMH = @IDMH
	end

--exec
declare @a float ,@b nvarchar(30) , @c char (5)
exec LopKemNhat 'MH02','kid', @a output , @b output , @c output
select Diem,TenLop,TTLopHoc.IDLH
from Diem,TTLopHoc,HocVien
where HocVien.IDHV = Diem.IDHV AND TTLopHoc.IDLH = HocVien.IDLH 
	  AND Diem = @a AND TenLop = @b AND TTLopHoc.IDLH = @c

----------Trigger------------
alter trigger _ttLopHoc
On TTLopHoc 
For Insert
As	
	if (select Count(TenLop) from TTLopHoc where TenLop = (select TenLop from inserted)) < 2
	begin
		print N'Tên l?p nh?p sai! Xin h?y nh?p l?i ðúng tên l?p s?n có!'
		rollback tran
	end
	
	else if (select LEFT(IDLH ,3) from inserted) not like 'LH0'
	begin
		print  N'B?n ð? nh?p sai IDLH!! IDLH ph?i b?t ð?u b?ng "LH0 + Number".'
		print N'Xin vui l?ng nh?p l?i'
		rollback tran
	end

	else if (select SoHocVien from inserted) is not null
	begin 
		print N'S? H?c Viên không ðý?c phép c?p nh?t!!'
		rollback tran
	end
	
	---
Create trigger _TimeLopHoc
On TimeLopHoc
For Insert,Update
As 
	if (select TimeStart from inserted) > 24
	begin
		print N'Yêu c?u nh?p ðúng s? gi? b?t ð?u!'
		print N'S? gi? b?t ð?u không ðý?c quá 24 gi?.'
		rollback tran
	end
	
	else if (select TimeStart from inserted) <0
	begin
print N'Yêu c?u nh?p ðúng s? gi? b?t ð?u!'
		print N'S? gi? b?t ð?u không ðý?c < 0.'
		rollback tran
	end
	
	else if (select TimeEnd from inserted) > 24
	begin
		print N'Yêu c?u nh?p ðúng s? gi? k?t thúc!'
		rollback tran
	end
	
	else if (select TimeEnd from inserted) <0
	begin
		print N'Yêu c?u nh?p ðúng s? gi? k?t thúc!'
		print N'S? gi? k?t thúc không ðý?c < 0.'
		rollback tran
	end
	
	else if (select TimeEnd - TimeStart from inserted) < 2
	begin 
		print N'B?n ð? nh?p sai s? gi? bu?i h?c! Xin h?y nh?p ðúng s? gi? bu?i h?c.'
		print N'S? gi? bu?i h?c ít nh?t là 2 gi? '
		rollback tran
	end
	
	else if (select RIGHT(NgayHoc,1) from inserted ) > 8 
	begin
		print N'Yêu c?u nh?p ðúng ngày h?c!'
		print N'Ngày h?c không ðý?c vý?t quá 8 ngày.'
		rollback tran
	end
	
	else if (select RIGHT(NgayHoc,2) from inserted ) < 2 
	begin
		print N'Yêu c?u nh?p ðúng ngày h?c!'
		print N'Ngày h?c ít nh?t ph?i b?t ð?u b?ng th? 2.'
		rollback tran
	end
	
	else if (select RIGHT(NgayHoc,2) from inserted ) is null
	begin
		print N'Yêu c?u nh?p ngày h?c!'
		print N'Ngày h?c không ðý?c phép null.'
		rollback tran
	end
	
------------Tran------------
select * from TimeLopHoc
insert into TimeLopHoc values ('LH02','2','4',N'Th? 3', 0, '48')
delete from TimeLopHoc where MaxSoBuoi = 48
------Giao d?ch xóa l?p h?c trong TimeStart() TimeEND() IDLH()---------
	Begin tran xoaLop
	Delete TimeLopHoc where TimeStart = '2' AND TimeEnd = '4' AND IDLH = 'LH02'
	if (@@ROWCOUNT  > 1)
		begin
			print N'H?y xóa l?p'
			Rollback tran xoaLop
		end
	else 
		begin
			Commit tran xoaLop
			print N'Th?c hi?n xóa l?p'
		end