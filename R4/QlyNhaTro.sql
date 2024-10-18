-- Của Quân 




-- Tạo database
CREATE DATABASE QLyNhaTro;
GO

USE QLyNhaTro;
GO

-- Tạo bảng Chủ trọ
CREATE TABLE ChuTro (
    CT_IDChuTro INT PRIMARY KEY,
    CT_TenChuTro VARCHAR(100),
    CT_SoDienThoai VARCHAR(15),
    CT_TenTaiKhoan VARCHAR(50),
    CT_MatKhau VARCHAR(100)
);

-- Tạo bảng Phòng
CREATE TABLE Phong (
    P_id INT PRIMARY KEY,
    P_sophong INT,
    P_giaphong INT,
    P_tinhtrangphong NVARCHAR(50)
);

-- Tạo bảng Người thuê phòng
CREATE TABLE NguoiThuePhong (
    NTP_IDnguoithuephong INT PRIMARY KEY,
    P_id INT,
    NTP_tenkhach VARCHAR(100),
    NTP_anhcancuoc VARBINARY(MAX),
    NTP_sodienthoai VARCHAR(15),
    NTP_tentaikhoan VARCHAR(50),
    NTP_matkhau VARCHAR(100),
    FOREIGN KEY (P_id) REFERENCES Phong(P_id)
);

-- Tạo bảng Bảng hóa đơn
CREATE TABLE BangHoaDon (
    BHD_idBanghoadon INT PRIMARY KEY,
    P_ID INT,
    BHD_ngaylaphoadon DATE,
    BHD_tongsotien INT,
    BHD_tienphong INT,
    FOREIGN KEY (P_ID) REFERENCES Phong(P_id)
);

-- Tạo bảng Minh chứng
CREATE TABLE MinhChung (
    MC_id INT PRIMARY KEY,
    BHD_idBanghoadon INT,
    MC_anhminhchung VARBINARY(MAX),
    FOREIGN KEY (BHD_idBanghoadon) REFERENCES BangHoaDon(BHD_idBanghoadon)
);

-- Tạo bảng Hóa đơn dịch vụ
CREATE TABLE HoaDonDichVu (
    HDDV_idhoadondichvu INT PRIMARY KEY,
    BHD_idBanghoadon INT,
    HDDV_soluongDV INT,
    HDDV_tiencuaDV INT,
    FOREIGN KEY (BHD_idBanghoadon) REFERENCES BangHoaDon(BHD_idBanghoadon)
);

-- Tạo bảng Hợp đồng
CREATE TABLE HopDong (
    HD_mahopdong INT PRIMARY KEY,
    P_id INT,
    HD_tienphong INT,
    HD_ngaybatdauthue DATE,
    HD_thoihanthue VARCHAR(50),
    HD_anhhopdong VARBINARY(MAX),
    FOREIGN KEY (P_id) REFERENCES Phong(P_id)
);

-- Tạo bảng Dịch vụ
CREATE TABLE DichVu (
    DV_iddichvu INT PRIMARY KEY,
    HDDV_idhoadondichvu INT,
    DV_tendichvu VARCHAR(50),
    DV_tiencuadichvu INT
);
-- Tạo bảng Hd_Dv (Liên kết giữa Hóa đơn dịch vụ và Dịch vụ)
CREATE TABLE Hd_Dv (
	DV_iddichvu INT,
	HDDV_idhoadondichvu INT,
	tiendichvu INT,
	PRIMARY KEY (DV_iddichvu, HDDV_idhoadondichvu),
	FOREIGN KEY (DV_iddichvu) REFERENCES DichVu(DV_iddichvu),
	FOREIGN KEY (HDDV_idhoadondichvu) REFERENCES HoaDonDichVu(HDDV_idhoadondichvu)
);


-- Tạo stored procedure để thêm hợp đồng mới
go
CREATE OR ALTER PROC ThemHopDong
    @P_id INT,                -- ID Phòng
    @HD_tienphong INT,        -- Tiền phòng
    @HD_ngaybatdauthue DATE,  -- Ngày bắt đầu thuê
    @HD_thoihanthue VARCHAR(50), -- Thời hạn thuê
    @HD_anhhopdong VARBINARY(MAX) -- Ảnh hợp đồng
AS
BEGIN
    -- Thêm bản ghi hợp đồng mới
    INSERT INTO HopDong (P_id, HD_tienphong, HD_ngaybatdauthue, HD_thoihanthue, HD_anhhopdong)
    VALUES (@P_id, @HD_tienphong, @HD_ngaybatdauthue, @HD_thoihanthue, @HD_anhhopdong);
    -- Trả về thông báo thành công
    PRINT 'Hợp đồng mới đã được thêm thành công!';
END;


-- Tạo stored procedure để cập nhật thông tin hợp đồng
GO
CREATE OR ALTER PROC CapNhatHopDong
    @HD_mahopdong INT,        -- Mã hợp đồng cần cập nhật
    @HD_tienphong INT,        -- Tiền phòng mới
    @HD_thoihanthue VARCHAR(50), -- Thời hạn thuê mới
    @HD_ngaybatdauthue DATE,  -- Ngày bắt đầu thuê mới
    @HD_anhhopdong VARBINARY(MAX) -- Ảnh hợp đồng mới (nếu có)
AS
BEGIN
    -- Cập nhật bản ghi hợp đồng theo mã hợp đồng
    UPDATE HopDong
    SET HD_tienphong = @HD_tienphong, 
        HD_thoihanthue = @HD_thoihanthue,
        HD_ngaybatdauthue = @HD_ngaybatdauthue,
        HD_anhhopdong = @HD_anhhopdong
    WHERE HD_mahopdong = @HD_mahopdong;
    
    -- Trả về thông báo thành công
    PRINT 'Thông tin hợp đồng đã được cập nhật thành công!';
END;


-- tìm kiếm hợp đồng theo phòng
GO
CREATE OR ALTER PROC TimKiemHopDongTheoPhong
    @P_id INT -- Mã phòng
AS
BEGIN
    SELECT * FROM HopDong
    WHERE P_id = @P_id;
END;

-- xây dựng modunl hợp đồng
go
create or alter proc dumpHopDong
as
begin
	DECLARE @i INT = 1;
	WHILE @i <= 1000
	BEGIN
		INSERT INTO HopDong (HD_mahopdong, P_id, HD_tienphong, HD_ngaybatdauthue, HD_thoihanthue, HD_anhhopdong)
		VALUES (@i, 
				ABS(CHECKSUM(NEWID()) % 100) + 1, 
				ABS(CHECKSUM(NEWID()) % 500000) + 100000, 
				DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 30), GETDATE()), 
				CONCAT(ABS(CHECKSUM(NEWID()) % 12) + 1, ' tháng'),  
				NULL);  

		SET @i = @i + 1;
	END;
end

exec dumpHopDong

---dump Bảng MinhChung
create or alter proc dumpMinhChung
as
begin
	declare @MC_id int=1,
		@BHD_idBHD int,
		@MC_anhminhchung varbinary
	while @MC_id<=1000
	begin
		select top 1 @BHD_idBHD=BHD_idBanghoadon
		from HoaDonDichVu
		order by NEWID()
		set @MC_id=@MC_id+1
		set @MC_anhminhchung=convert(varbinary(max),newid())
		set @MC_anhminhchung=CAST(REPLICATE(0x4, 1) AS VARBINARY(MAX)) 
		insert into MinhChung(MC_id,BHD_idBanghoadon,MC_anhminhchung) values (@MC_id,@BHD_idBHD,@MC_anhminhchung)
		
	end
end
exec dumpMinhChung
select * from MinhChung
---1.Cập nhật trạng thái hóa đơn sau khi đã xác minh minh chứng
alter table BangHoaDon add TrangThai nvarchar(50)
create or alter trigger tTrangThaiHD
on MinhChung
after insert
as
begin
	update BangHoaDon
	set Trangthai=N'Đã xác minh'
	where BHD_idBanghoadon in (select BHD_idBanghoadon from inserted)
end

select * from BangHoaDon

--2.Kiểm tra tính hợp lệ của dữ liệu (ảnh minh chứng)
create or alter proc ThemAnhMC
    @mc_id int,
    @bhd_idbanghoadon int,
    @mc_anhminhchung varbinary(max)
as
begin

    if @mc_anhminhchung is not null and substring(@mc_anhminhchung, 1, 2) != 0xffd8 and 
       substring(@mc_anhminhchung, 1, 4) != 0x89504e47
    begin
        raiserror(N'Ảnh chèn không hợp lệ', 16, 1);
        return;
    endM
    insert into minhchung (MC_id, BHD_idBanghoadon, MC_anhminhchung)
    values (@mc_id, @bhd_idbanghoadon, @mc_anhminhchung);
end;
exec ThemAnhMC


--3,Thêm minh chứng mới
create or alter trigger ThemMC
on MinhChung
instead of insert
as
begin
	if exists (select 1 from MinhChung
				join inserted on MinhChung.MC_id=inserted.MC_id 
				and MinhChung.BHD_idBanghoadon=inserted.BHD_idBanghoadon)
	begin
		print N'Đã tồn tại mã minh chứng và mã hóa đơn'
		rollback
	end
	insert into MinhChung(MC_id,BHD_idBanghoadon,MC_anhminhchung)
	select MC_id,BHD_idBanghoadon,MC_anhminhchung from inserted
end
