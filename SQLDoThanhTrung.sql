-- Trigger
 -- viết 1 trigger để đảm bảo rằng khi thêm 1 bản ghi vào bảng học viên thì IDHV phải chưa có trong csdl
 Create trigger add_bg
 on HocVien for insert 
 as
 if (select COUNT (IDHV) from HocVien
    where IDHV like ( select IDHV from inserted ))>=2
    begin
    print N'không thêm được'
    rollback tran
    end
    
   
 -- Tự động cập nhập số học viên vào bảng TTLopHoc

 create trigger tdcn_shv
 on thongTinChiTietLopHoc instead of insert 
 as
 insert into TTLopHoc(SoHocVien) select SoHoVien from thongTinChiTietLopHoc where IDLH=(Select IDLH from INSERTED)
-- Con trỏ ( cur )
 -- Dùng con trỏ để tính số lượng của học viên trong Trung Tâm Dạy Học
declare cur_HocVien cursor
read_only scroll
for 
select  * from HocVien
open cur_HocVien
declare @SoLuong int
set @SoLuong=0
fetch first from cur_HocVien
while @@FETCH_STATUS=0
begin
set @SoLuong=@SoLuong+1
fetch next from cur_HocVien 
end
print N'so hoc vien' + cast(@Soluong as char(20))
close cur_HocVien
deallocate cur_HocVien



--View
alter view thongTinChiTietHocVien
as
select distinct HocVien.IDHV, HocVien.HoTen as HoTenHV, HocVien.SoDT, HocVien.DiaChi, 
HocVien.Email, HocVien.GioiTinh, YEAR(GETDATE())-YEAR(HocVien.NgaySinh) as Tuoi, TTLopHoc.TenLop, 
TTGiangVien.HoTen as HoTenGV, MonHoc.KhoiMonHoc, MonHoc.TenMonHoc, Diem.Diem
from HocVien, MonHoc, TTGiangVien, TTLopHoc, Diem, TimeLopHoc
where TTLopHoc.IDLH = HocVien.IDLH and HocVien.IDHV = Diem.IDHV and MonHoc.IDMH=Diem.IDMH and 
TTLopHoc.IDGV=TTGiangVien.IDGV and TTLopHoc.IDLH = TimeLopHoc.IDLH 
select * from thongTinChiTietHocVien
--Thủ tục 
 -- Viết 1 thủ tục hiển thị IDHV, HoTen, Diem, của những học viên có điểm thi môn Lập trình game nâng cao 
  create proc svcodiemcaonhat
  as
  begin
  declare @IDMH char(10)
  select @IDMH = MonHoc.IDMH from MonHoc
  where MonHoc.TenMonHoc = N'unity'
  declare @maxdiem float
  select @maxdiem = MAX(Diem) from Diem
  where Diem.IDMH=@IDMH
  Select HocVien.IDHV, HocVien.HoTen, Diem.Diem from HocVien,Diem
  where HocVien.IDHV = Diem.IDHV
  and Diem.Diem = @maxdiem
  and Diem.IDMH =@IDMH
  end
  
 exec  svcodiemcaonhat 
  
  
  
  -- viết 1 thủ tục để thêm 1 học viên vào trong bảng HocVien chú ý kiểm tra xem có trùng không ?
create proc TH4_add_hocvien
@IDHV char(10), @HoTen char(10),@IDLH char(10),@SoDT char(15), @DiaChi nvarchar(100), @Email nvarchar(30), @GioiTinh nvarchar(3), @NgaySinh date
as
begin 
if(exists (select *from HocVien where IDHV=@idhv))
	print N'không thể thêm học viên vì idhv đã tồn tại '
else
insert into HocVien values (@IDHV , @HoTen ,@IDLH ,@SoDT , @DiaChi , @Email , @GioiTinh , @NgaySinh )
end

 --viết 1 hàm trả về danh sách học viên học môn unity , tên môn đc truyền vào qua tham số
 create function sohv (@TenMonHoc nvarchar(30))
 returns @bien table ( IDHV char(10),HoTen nvarchar(30))
 as 
 begin
   insert into @bien
   select HocVien.IDHV, HocVien.HoTen
   from HocVien, Diem, MonHoc
   where HocVien.IDHV = Diem.IDHV
   and Diem.IDMH = MonHoc.IDMH
   and MonHoc.TenMonHoc = @TenMonHoc
   return 
   end
   
   select * from sohv (N'unity')
-- Giao dịch về học viên 
 -- viết giao dịch thêm 1 học viên vào bảng học viên 
 Begin tran Tran_delete 
 Delete from HocVien 
 where HoTen = N'Nguyễn Thị Bo'
 if ( @@ROWCOUNT > 1)
   begin 
     rollback tran Tran_delete
     print N' hủy xóa học viên'
   end
 else 
    begin
       Commit tran Tran_deletey
       Print N'Thực hiện xóa CSDL'
    end    
 
 insert into HocVien 
 values ('HV017','LH01',N'Nguyễn Thị Bo','0978415263',N'62 Tôn Thất Tùng',N'nguyenthiBo@gmail.com',N'Nữ','02/2/1996')
 insert into HocVien 
 values ('HV018','LH01',N'Nguyễn Thị Bo','0978405267',N'62 Tôn Thất Tùng',N'nguyenthiBoo@gmail.com',N'Nữ','02/2/1996')
 delete from HocVien
 where IDHV = 'HV018'
 select * from HocVien