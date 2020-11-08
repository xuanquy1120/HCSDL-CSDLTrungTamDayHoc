
Create database QuanLyTrungTamDayHoc
on primary
(
	name = QuanLyLopHoc,
	filename = 'E:\BAI_TAP_LON_SQL\QuanLyTrungTamDayHoc.mdf',
	size = 10MB,
	maxsize = Unlimited,
	filegrowth = 2MB
)
log on
(
name = QuanLyLopHoc_log,
	filename = 'E:\BAI_TAP_LON_SQL\QuanLyTrungTamDayHoc_log.ldf',
	size = 5MB,
	maxsize = Unlimited,
	filegrowth = 1MB
)
use QuanLyTrungTamDayHoc

create table TTGiangVien(
IDGV char(10) not null primary key,
HoTen nvarchar(30),
SoDT char(15) unique, 
DiaChi nvarchar(100),
Email nvarchar(30) unique,
GioiTinh nvarchar(3),
NgaySinh date,
check (GioiTinh =N'Nam' or GioiTinh=N'Nữ'),
check (Email like ('%@%')),
)

create table MonHoc(
IDMH char(10) not null primary key,
TenMonHoc nvarchar(30),
MotaMonHoc nvarchar(250),
KhoiMonHoc nvarchar(10),
)
 
create table TTLopHoc(
IDLH char(10) not null primary key,
TenLop nvarchar(30),
SoHocVien int,
IDGV char(10) foreign key references TTGiangVien(IDGV),
IDMH char(10) foreign key references MonHoc(IDMH),
)
create table TimeLopHoc(
IDLH char(10) foreign key references TTLopHoc(IDLH),
TimeStart int,
TimeEnd int,
NgayHoc nvarchar(15),
SoBuoi int,
MaxSoBuoi int,
)
create table HocVien(
IDHV char(10) not null primary key,
IDLH char(10) foreign key references TTLopHoc(IDLH),
HoTen nvarchar(30),
SoDT char(15) unique, 
DiaChi nvarchar(100),
Email nvarchar(30) unique,
GioiTinh nvarchar(3),
NgaySinh date,
check (GioiTinh =N'Nam' or GioiTinh=N'Nữ'),
check (Email like ('%@%'))
)

create table Diem(
IDHV char(10) foreign key references HocVien(IDHV),
IDMH char(10) foreign key references MonHoc(IDMH),
Diem float,
)
create table LuongGV(
IDGV char(10) foreign key references TTGiangVien(IDGV),
TongSoGioKid int,
LuongKhoiKid float,
TongSoGioTeen int,
LuongKhoiTeen float,
TongSoGio18 int,
LuongKhoi18 float,
TongLuong float,
TongSoGio int
)

insert into TTGiangVien 
values 
('GV01',N'Đỗ Hoàng Long', '0336804998',N'71 Hang Dieu', N'long01@gmail.com', N'Nam','11/07/1998'),
('GV02',N'Nguyễn Xuân Quý', '034685123',N'23 Tây Sơn', N'quy01@gmail.com', N'Nam','01/01/2000'),
('GV03',N'Đỗ Thành Trung', '035894645',N'357 Nguyễn Trãi', N'trung01@gmail.com', N'Nam','12/05/1999'),
('GV04',N'Ngô Thị Duyên', '0312466789', N'83 Trường chinh', N'duyen@gmail.com', N'Nữ','02/02/1998'),
('GV05',N'Nguyễn Văn Cường', '0356124789',N'192 Lê Trọng Tấn',N'cuong05@gmail.com', N'Nam','12/02/2000')
Insert into MonHoc values
('MH01',N'javascript ',N'Tạp trang web','18+'),
('MH02',N'scratch',N'làm trò chơi cơ bản','Kid'),
('MH03',N'unity',N'làm lập trình game nâng cao','Teen'),
('MH04',N'React Native',N'xây dụng ứng dụng','18+'),
('MH05',N'GameMaker',N'Làm game chuyên xâu','Teen'),
('MH06',N'Kodu',N'Lập trình game cơ bản','Kid')
Insert into TTLopHoc values 
('LH01',N'Lập trình web',null,'GV01','MH01'),
('LH02',N'lập trình game cơ bản',null,'GV02','MH02'),
('LH03',N'lập trình game chuyên sâu',null,'GV03','MH03'),
('LH04',N'Lập trình ứng dụng',null,'GV04','MH04'),
('LH05',N'lập trình game nâng cao',null,'GV05','MH05'),
('LH06',N'Lập trình game 3D cơ bản',null,'GV01','MH06'),
('LH07',N'Lập trình web',null,'GV02','MH01'),
('LH08',N'lập trình game cơ bản',null,'GV03','MH02')
insert into HocVien 
values
('HV01','LH01',N'Nguyễn Văn A','098378426',N'62 Tôn Thất Tùng',N'nguyenvanA@gmail.com',N'Nam','02/2/1996'),
('HV02','LH01',N'Nguyễn Thị B','095738471',N'28 Linh Lang',N'nguyenthiB@gmail.com',N'Nữ','10/2/2000'),
('HV03','LH02',N'Nguyên Văn C','093569315',N'78 Đào Tấn',N'nguyennamC@gmail.com',N'Nam','12/3/2008'),
('HV04','LH02',N'Nguyễn Văn D','09999999',N'12 Lê trọng tấn',N'nguyenvanD@gmail.com',N'Nam','02/25/2006'),
('HV05','LH03',N'Nguyễn Thị F','0931245687',N'28 Minh Khai',N'nguyenthiF@gmail.com',N'Nữ','10/9/2004'),
('HV06','LH03',N'Nguyên Văn G','0978456312',N'34 Trường Chinh',N'nguyennamG@gmail.com',N'Nam','12/3/2005'),
('HV07','LH04',N'Nguyễn Văn H','09878456312',N'2 Tôn Thất Tùng',N'nguyenvanH@gmail.com',N'Nam','02/25/1996'),
('HV08','LH04',N'Nguyễn Thị J','0912345786',N'9 Linh Đàm',N'nguyenthiJ@gmail.com',N'Nữ','10/9/1999'),
('HV09','LH05',N'Nguyên Văn K','0987451263',N'34 Triều Khúc',N'nguyennamK@gmail.com',N'Nam','2/1/2005'),
('HV010','LH05',N'Nguyễn Văn L','0978451263',N'62 Phùng Khoang',N'nguyenvanL@gmail.com',N'Nam','02/3/2005'),
('HV011','LH06',N'Nguyễn Thị Z','0936251478',N'28 Nguyễn trãi',N'nguyenthiZ@gmail.com',N'Nữ','10/9/2008'),
('HV012','LH06',N'Nguyễn Văn X','0912456378',N'624 Phố Huế',N'nguyenvanX@gmail.com',N'Nam','02/2/2009'),
('HV013','LH07',N'Nguyễn Thị O','0916432578',N'56 Trần Duy Hưng',N'nguyenthiO@gmail.com',N'Nữ','10/9/1998'),
('HV014','LH07',N'Nguyễn Văn V','0973854612',N'67 Lê trọng tấn',N'nguyenvanV@gmail.com',N'Nam','02/2/1996'),
('HV015','LH08',N'Nguyễn Thị N','0918452367',N'28 Nguyễn Quý Đức',N'nguyenthiN@gmail.com',N'Nữ','1/8/2008'),
('HV016','LH08',N'Nguyễn Văn M','0987451236',N'123 Đường Láng',N'nguyenvanM@gmail.com',N'Nam','2/8/2008')

Insert into TimeLopHoc
values
('LH01',7,10,N'Thứ 2',0,'72'),
('LH02',10,12,N'Thứ 4',0,'24'),
('LH03',14,16,N'Thứ 6',0,'36'),
('LH04',7,10,N'Thứ 3',0,'72'),
('LH05',10,12,N'Thứ 5',0,'24'),
('LH06',14,16,N'Thứ 7',0,'36'),
('LH07',19,22,N'Thứ 2',0,'72'),
('LH08',16,18,N'Thứ 4',0,'24')
insert into Diem
values
('HV01','MH01',7),
('HV02','MH01',8),
('HV03','MH02',9),
('HV04','MH02',4),
('HV05','MH03',3),
('HV06','MH03',5),
('HV07','MH04',6),
('HV08','MH04',8),
('HV09','MH05',7),
('HV010','MH05',9),
('HV011','MH06',4),
('HV012','MH06',6),
('HV013','MH01',5),
('HV014','MH01',10),
('HV015','MH02',8),
('HV016','MH02',7)
Insert into LuongGV
values
('GV01',0,0,0,0,0,0,0,0),
('GV02',0,0,0,0,0,0,0,0),
('GV03',0,0,0,0,0,0,0,0),
('GV04',0,0,0,0,0,0,0,0),
('GV05',0,0,0,0,0,0,0,0)

delete from LuongGV
select * from TTGiangVien
select * from TTLopHoc
select * from Diem
select * from HocVien
select * from TimeLopHoc
select * from LuongGV
select * from MonHoc






