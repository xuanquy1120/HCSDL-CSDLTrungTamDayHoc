-- function --
-- function tính tổng số học viên trong một lớp, với tham số truyền vào là idlh (của trung) --
alter function SoHocVien
(@idlh char(10))
returns int
as begin
declare @SHV int
select @SHV = COUNT(IDHV) from HocVien,TTLopHoc 
where TTLopHoc.IDLH=HocVien.IDLH and TTLopHoc.IDLH = @idlh
return @SHV
end
select dbo.SoHocVien('LH01') as SoHoVien
-- function tính tổng số lớp dạy, với idgv là tham số truyền vào
create function f_TongSoLopGVDay
(@idgv char(10))
returns float
as begin
declare cur_tsLop cursor
read_only scroll 
for 
select IDLH from TTLopHoc where IDGV=@idgv
open cur_tsLop
declare  @idlh char(10),@TongSoLop  int
set @TongSoLop  = 0
	fetch first from cur_tsLop into @idlh
	while (@@FETCH_STATUS=0)
	begin
		set @TongSoLop = @TongSoLop + 1
		fetch next from cur_tsLop into @idlh
	end
close cur_tsLop
deallocate cur_tsLop
return @TongSoLop 
end
select dbo.f_TongSoLopGVDay('GV02') as TongSoLop
--function kiểm tra giảng viên lớp học có bị trùng thời gian hay không 1 có 0 là không(để sắp xếp lớp dạy học)

alter function f_GVBiTrung
(@NgayHoc nvarchar(15), @timeStart int, @idGiangVien char(10))
returns int
as 
begin
	declare cur_list cursor
	read_only scroll 
	for 
	select TimeLopHoc.TimeStart,TimeLopHoc.NgayHoc 
	from TimeLopHoc,TTLopHoc where TTLopHoc.IDLH = TimeLopHoc.IDLH and TTLopHoc.IDGV=@idGiangVien
	open cur_list
	declare @tStart int,@NH nvarchar(15),@KiemTra int
	set @KiemTra = 0
	fetch first from cur_list into @tStart,@NH
	while (@@FETCH_STATUS=0)
	begin
		if(@NH = @NgayHoc and @tStart = @timeStart)
			begin
				set @KiemTra = 1
				fetch next from cur_list into @tStart,@NH
			end
		else
		begin
			fetch next from cur_list into @tStart,@NH
		end	
	end
close cur_list
deallocate cur_list
return @KiemTra
end
select dbo.f_GVBiTrung(N'Thứ 2','7','GV06');
select dbo.f_GVBiTrung(N'Thứ 4','10','GV02');
--function danh sách các giảng viên không bị trùng khung giờ
create function f_listGVkhongBiTrungGio
(@NgayHoc nvarchar(15), @timeStart int)
returns @listGV table(IDGV char(10), HoTen nvarchar(30))
as begin
	declare cur_list cursor
	read_only scroll 
	for 
	select IDGV from TTLopHoc
	open cur_list
	declare @idgv char(10)
	fetch first from cur_list into @idgv
	while (@@FETCH_STATUS=0)
	begin
		if(dbo.f_GVBiTrung(@NgayHoc,@timeStart,@idgv)=0)
			begin
			insert into @listGV
				select IDGV,HoTen
				from TTGiangVien where IDGV=@idgv
				fetch next from cur_list into @idgv
			end
		else
		begin
			fetch next from cur_list into @idgv
		end	
	end
close cur_list
deallocate cur_list
return 
end
select distinct * from f_listGVkhongBiTrungGio(N'Thứ 6','14');
select *from TimeLopHoc
select * from TTGiangVien

--   View  --
-- View có thông tin chi tiết của học viên (idhv,tên hv, số điện thoại, địa chỉ, email, giới tính, tuổi, tên lớp đang học, têngv dạy, khối môn học, tên môn học, điểm, sô buổi đã được học)

-- view co thong tin chi tiet cua cac lop hoc (của trung)( tên lớp, idlh, khối học, tên môn học, giảng viên dạy, số buổi đã học, max số buổi học, sô buổi học còn lại, số học viên học, time bắt đầy, time kết thúc, ngày học)
create view thongTinChiTietLopHoc
as
select distinct TTLopHoc.IDLH, TTLopHoc.TenLop as tenLopHoc, MonHoc.KhoiMonHoc, MonHoc.TenMonHoc, TTGiangVien.HoTen as TenGV, TTGiangVien.IDGV,
TimeLopHoc.SoBuoi, TimeLopHoc.MaxSoBuoi, (TimeLopHoc.MaxSoBuoi- TimeLopHoc.SoBuoi) as SoBuoiHocConLai, dbo.SoHocVien(TTLopHoc.IDLH) as SoHoVien,
TimeLopHoc.TimeStart, TimeLopHoc.TimeEnd, TimeLopHoc.NgayHoc
from TTLopHoc, MonHoc, TTGiangVien, TimeLopHoc,HocVien
where TTLopHoc.IDLH = HocVien.IDLH and TTLopHoc.IDLH = TimeLopHoc.IDLH and TTLopHoc.IDGV= TTGiangVien.IDGV and TTLopHoc.IDMH = MonHoc.IDMH
select * from thongTinChiTietLopHoc
-- view thong tin khoi hoc cua lop
create view ThongTinChiTietVeGV
as
select distinct LuongGV.IDGV, TTGiangVien.HoTen,  YEAR(GETDATE())-YEAR(TTGiangVien.NgaySinh) as Tuoi, 
TTGiangVien.DiaChi,TTGiangVien.SoDT,TTGiangVien.Email,TTGiangVien.GioiTinh,LuongGV.TongSoGio,LuongGV.TongLuong
from LuongGV,thongTinChiTietLopHoc, TTGiangVien
where LuongGV.IDGV = thongTinChiTietLopHoc.IDGV and LuongGV.IDGV = TTGiangVien.IDGV
select * from ThongTinChiTietVeGV
-- proc check số buổi
create PROC p_TangSoBuoi
@idlh char(10), @SB INT output
as BEGIN
SET @SB= 1 + (SELECT SoBuoi FROM TimeLopHoc 
WHERE IDLH= @idlh)
UPDATE TimeLopHoc
	SET SoBuoi = @SB
	WHERE IDLH=@idlh
end
delete from TimeLopHoc
-- thuc thi check số buổi tập
DECLARE @a INT
EXEC p_TangSoBuoi 'LH01', @a OUTPUT
PRINT @a 
select * from LuongGV
select * from thongTinChiTietLopHoc
-- proc them tt giang vien
create proc p_addGiangVien
@idgv char(10), @tenGV nvarchar(30), @sdt char(15), @DiaChi nvarchar(100), @email nvarchar(30), @gt nvarchar(3), @ns date
as
begin 
if(exists (select *from TTGiangVien where IDGV=@idgv))
	print N'không thể thêm giảng viên vì đã tồn tại'
else
insert into TTGiangVien values (@idgv,@tenGV,@sdt,@DiaChi,@email,@gt,@ns)
end
-- thuc thi

delete from LuongGV
where IDGV='GV06'
exec p_addGiangVien 'GV06',N'Nguyễn Thanh Tùng','094561283','99 Nguyễn Chí Thanh','tung@gmail.com','nam','6/6/1994'
select * from LuongGV
--  Trigger --
-- trigger thêm thông tin học viên và kiểm tra xem lớp có phù hợp với độ tuổi không
create trigger ThemThongTinHocVien
on HocVien for insert
as
declare @Sotuoi int
declare @KH char(10)
set @Sotuoi=(select (YEAR(GETDATE())-YEAR(HocVien.NgaySinh)) from HocVien
where IDHV like(select IDHV from inserted))
if( @Sotuoi >= 12  and @Sotuoi <= 14)
begin
	set @KH = (select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) )
	if(
	(select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) ) like 'Kid'
	)
	begin
		print N'Đã thêm học viên vào lớp khối kid thành công'
	end
	else
	begin
		print N'Độ tuổi không thích hợp để học khối ' + @KH
		rollback tran
	end
end
else if( @Sotuoi >= 15  and @Sotuoi <= 17)
begin
	set @KH = (select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) )
	if(
	(select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) ) like 'Teen'
	)
	begin
		print N'Đã thêm học viên vào lớp khối Teen thành công'
	end
	else
	begin
		print N'Độ tuổi không thích hợp để học khối ' +@KH
		rollback tran
	end
end
else if( @Sotuoi > 18)
begin
	set @KH = (select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) )
	if(
	(select KhoiMonHoc from MonHoc
	where IDMH = (select IDMH from TTLopHoc
	where IDLH = (select IDLH from inserted)) ) like '18+'
	)
	begin
		print N'Đã thêm học viên vào lớp khối 18+ thành công'
	end
	else
	begin
		print N'Độ tuổi không thích hợp để học khối ' +@KH
		rollback tran
	end
end
else
	begin
		print N'Độ tuổi quá nhỏ để học bất kỳ khối nào'
		rollback tran
	end
insert into HocVien 
values
('HV017','LH05',N'Nguyễn Văn Hà','0956412378',N'123 Nguyễn Trãi',N'nguyenvanha@gmail.com',N'Nam','02/02/2008')
select * from thongTinChiTietLopHoc
-- trigger tự cập nhật tổng lương

alter TRIGGER TG_AutoUpdateSoGioGV
ON TimeLopHoc for update
AS 
if((select KhoiMonHoc from thongTinChiTietLopHoc where IDLH = (select IDLH from inserted))='Kid')
	begin
	UPDATE LuongGV
		SET TongSoGioKid = TongSoGioKid + (select TimeEnd-TimeStart from TimeLopHoc where IDLH = (select IDLH from inserted))
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET LuongKhoiKid = TongSoGioKid *100000,
			TongSoGio = TongSoGioKid + TongSoGioTeen + TongSoGio18
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET TongLuong = LuongKhoiKid +LuongKhoi18 +LuongKhoiTeen
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	end
else if((select KhoiMonHoc from thongTinChiTietLopHoc where IDLH = (select IDLH from inserted))='Teen')
	begin
	UPDATE LuongGV
		SET TongSoGioTeen = TongSoGioTeen + (select TimeEnd-TimeStart from TimeLopHoc where IDLH = (select IDLH from inserted))
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET LuongKhoiTeen = TongSoGioTeen *150000,
			TongSoGio = TongSoGioKid + TongSoGioTeen + TongSoGio18
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET TongLuong = LuongKhoiKid +LuongKhoi18 +LuongKhoiTeen
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	end
else if((select KhoiMonHoc from thongTinChiTietLopHoc where IDLH = (select IDLH from inserted))='18+')
	begin
	UPDATE LuongGV
		SET TongSoGio18 = TongSoGio18 + (select TimeEnd-TimeStart from TimeLopHoc where IDLH = (select IDLH from inserted))
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET LuongKhoi18 = TongSoGio18 *200000,
			TongSoGio = TongSoGioKid + TongSoGioTeen + TongSoGio18
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	UPDATE LuongGV
		SET TongLuong = LuongKhoiKid +LuongKhoi18 +LuongKhoiTeen
		where IDGV= (select IDGV from thongTinChiTietLopHoc where IDLH=(select IDLH from inserted))
	end
select * from LuongGV
-- trigger thêm lương giảng viên vào bảng luongGV
alter trigger TG_insertLuongGV
on TTGiangVien for insert
as
insert into LuongGV(IDGV) 
select IDGV from inserted
update LuongGV
	set TongSoGioKid=0,
		TongSoGioTeen=0,
		TongSoGio18=0,
		LuongKhoi18=0,
		LuongKhoiKid=0,
		LuongKhoiTeen=0,
		TongSoGio=0,
		TongLuong=0
	where IDGV =(select IDGV from inserted)
-- phan  Quyen --
use QuanLyTrungTamDayHoc
grant insert, select, update on dbo.LuongGV to [NguyenXuanQuy]
grant insert,select, update on dbo.TTGiangVien to [NguyenXuanQuy]
grant insert, select, update on dbo.TTLopHoc to [DoHoangLong]
grant insert,select, update on dbo.TimeLopHoc to [DoHoangLong]
grant insert,select, update on dbo.MonHoc to [DoHoangLong]
grant insert,select, update on dbo.HocVien to [DoThanhTrung]
grant insert,select, update on dbo.Diem to [DoThanhTrung]

-- giao dich transaticon
-- giao dịch chuyển giảng viên (thay giảng viên trong 1 lớp học)
alter proc trans_GVLopHoc
@idgv char(10), @idlh char(10)
as
begin tran Tran_GV
set tran isolation level serializable
if((exists (select * from TTLopHoc where IDLH=@idlh))
and
(exists (select * from TTGiangVien where IDGV=@idgv)))
	begin
		declare @id char(10),@NgayHoc nvarchar(15), @timeStart int
		set @id = (select IDGV from TTLopHoc where IDLH = @idlh)
		set @NgayHoc = (select NgayHoc from TimeLopHoc where IDLH=@idlh)
		set @timeStart = (select TimeStart from TimeLopHoc where IDLH=@idlh)
		if(dbo.f_GVBiTrung(@NgayHoc,@timeStart,@idgv)=0)
		begin
			update TTLopHoc
			set IDGV = @idgv
			where IDLH = @idlh
			commit tran Tran_GV
			print N'Lớp học có mã '+@idlh+N' Đã được thay giảng viên,từ giảng viên '+@id+N' Thành giảng viên '+@idgv
		end
		else
			begin
			print N'Thời gian của giảng viên ' + @idgv + N'Đã bị trùng'
			rollback tran
		end
	end
else
	begin
	print N'không tồn tại các ID giảng viên nhập vào hoặc ID lớp Học'
	rollback tran
end
exec trans_GVLopHoc 'GV04','LH05'
select * from TTLopHoc
select dbo.f_TongSoLopGVDay('GV01') as TongSoLop





