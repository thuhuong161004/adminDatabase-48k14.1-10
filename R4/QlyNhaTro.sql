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

