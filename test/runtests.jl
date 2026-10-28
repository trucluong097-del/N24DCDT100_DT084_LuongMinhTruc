# Lenh chay bo kiem thu; so phep kiem thuc te duoc Julia Test thong ke:
#   julia --startup-file=no test/runtests.jl

using Test
include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai

@testset "DT084 - Cac ca chuc nang va hoi quy co ID" begin

    @testset "T01 - Vi du 1 tren phieu giao (Cay 4 nut, muc 1 rong nhat)" begin
        goc = 1
        nut = [(1, 10, 2, 3), (2, 20, 4, 0), (3, 30, 0, 0), (4, 40, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[10], [20, 30], [40]]
        @test kq.day_theo_muc == [10, 20, 30, 40]
        @test kq.thu_tu_id == [1, 2, 3, 4]
        @test kq.do_rong == [1, 2, 1]
        @test kq.rong_nhat == 2
        @test kq.muc == 1
        @test kq.max_queue_len == 2
        @test kq.so_nut_vao_queue == 4
        @test kq.so_nut_ra_queue == 4
    end

    @testset "T02 - Vi du 2 tren phieu giao (Cay 1 nut goc)" begin
        goc = 1
        nut = [(1, 8, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[8]]
        @test kq.day_theo_muc == [8]
        @test kq.thu_tu_id == [1]
        @test kq.do_rong == [1]
        @test kq.rong_nhat == 1
        @test kq.muc == 0
        @test kq.max_queue_len == 1
        @test kq.so_nut_vao_queue == 1
        @test kq.so_nut_ra_queue == 1
    end

    @testset "T03 - Ca bien 1: Cay rong (n=0, goc=0)" begin
        goc = 0
        nut = Tuple{Int,Any,Int,Int}[]
        kq = giai_bai(goc, nut)
        @test isempty(kq.cac_muc)
        @test isempty(kq.day_theo_muc)
        @test isempty(kq.thu_tu_id)
        @test isempty(kq.do_rong)
        @test kq.rong_nhat == 0
        @test kq.muc === nothing
        @test kq.max_queue_len == 0
        @test kq.so_nut_vao_queue == 0
        @test kq.so_nut_ra_queue == 0
    end

    @testset "T04 - Ca bien 2: Goc co hai la (Cay 3 nut)" begin
        goc = 1
        nut = [(1, 100, 2, 3), (2, 200, 0, 0), (3, 300, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[100], [200, 300]]
        @test kq.do_rong == [1, 2]
        @test kq.rong_nhat == 2
        @test kq.muc == 1
        @test kq.max_queue_len == 2
    end

    @testset "T05 - Ca bien 3: Cay day phai 4 nut (lech phai hoan toan)" begin
        goc = 1
        nut = [(1, 10, 0, 2), (2, 20, 0, 3), (3, 30, 0, 4), (4, 40, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[10], [20], [30], [40]]
        @test kq.do_rong == [1, 1, 1, 1]
        # Tat ca cac muc cung rong 1 -> chon muc dau tien la muc 0
        @test kq.rong_nhat == 1
        @test kq.muc == 0
        # Dung luong queue toi da cua cay day xich luon la 1
        @test kq.max_queue_len == 1
    end

    @testset "T06 - Cay day du 7 nut (3 muc day du 1, 2, 4)" begin
        goc = 1
        nut = [
            (1, 1, 2, 3),
            (2, 2, 4, 5),
            (3, 3, 6, 7),
            (4, 4, 0, 0),
            (5, 5, 0, 0),
            (6, 6, 0, 0),
            (7, 7, 0, 0)
        ]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[1], [2, 3], [4, 5, 6, 7]]
        @test kq.do_rong == [1, 2, 4]
        @test kq.rong_nhat == 4
        @test kq.muc == 2
        # Dung luong queue toi da cua cay day dat 4
        @test kq.max_queue_len == 4
    end

    @testset "T07 - Ca tu thiet ke: Cay lech trai 4 nut" begin
        goc = 1
        nut = [(1, "A", 2, 0), (2, "B", 3, 0), (3, "C", 4, 0), (4, "D", 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [["A"], ["B"], ["C"], ["D"]]
        @test kq.day_theo_muc == ["A", "B", "C", "D"]
        @test kq.do_rong == [1, 1, 1, 1]
        @test kq.rong_nhat == 1
        @test kq.muc == 0
        @test kq.max_queue_len == 1
    end

    @testset "T08 - Ca tu thiet ke: Cay hinh dich dac (Zig-zag 4 nut)" begin
        # 1 -> con trai 2; 2 -> con phai 3; 3 -> con trai 4
        goc = 1
        nut = [(1, 10, 2, 0), (2, 20, 0, 3), (3, 30, 4, 0), (4, 40, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[10], [20], [30], [40]]
        @test kq.thu_tu_id == [1, 2, 3, 4]
        @test kq.do_rong == [1, 1, 1, 1]
        @test kq.rong_nhat == 1
        @test kq.muc == 0
        @test kq.max_queue_len == 1
    end

    @testset "T09 - Ca tu thiet ke: Cay co 3 muc hoa do rong (chon muc nho nhat)" begin
        # Cay 7 nut: muc 0 co 1 nut, muc 1 co 2 nut, muc 2 co 2 nut, muc 3 co 2 nut
        # goc 1 co con (2, 3). Nut 2 co con 4, nut 3 co con 5. Nut 4 co con 6, nut 5 co con 7.
        goc = 1
        nut = [
            (1, 1, 2, 3),
            (2, 2, 4, 0),
            (3, 3, 0, 5),
            (4, 4, 6, 0),
            (5, 5, 0, 7),
            (6, 6, 0, 0),
            (7, 7, 0, 0)
        ]
        kq = giai_bai(goc, nut)
        @test kq.cac_muc == [[1], [2, 3], [4, 5], [6, 7]]
        @test kq.do_rong == [1, 2, 2, 2]
        @test kq.rong_nhat == 2
        # Hoa giua cac muc 1, 2, 3 -> phai chon muc nho nhat la muc 1
        @test kq.muc == 1
    end

    @testset "T10 - Ca quy mo 15 nut: Cay nhi phan day du 4 muc" begin
        # n = 15: muc 0 (1), muc 1 (2), muc 2 (4), muc 3 (8)
        nut = Tuple{Int,Any,Int,Int}[]
        for i in 1:15
            trai = 2 * i <= 15 ? 2 * i : 0
            phai = 2 * i + 1 <= 15 ? 2 * i + 1 : 0
            push!(nut, (i, i, trai, phai))
        end
        kq = giai_bai(1, nut)
        @test kq.do_rong == [1, 2, 4, 8]
        @test kq.rong_nhat == 8
        @test kq.muc == 3
        @test kq.max_queue_len == 8
        @test kq.so_nut_vao_queue == 15
        @test kq.so_nut_ra_queue == 15
    end

    @testset "T11 - Ca kiem tra rang buoc hop dong va tu choi du lieu sai (Validator)" begin
        # 1. Goc vuot qua n
        @test_throws ArgumentError kiem_tra_dau_vao(5, [(1, 10, 0, 0)])

        # 2. Nut con tro vao chinh no (khuyen)
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 10, 1, 0)])

        # 3. Hai con trai va phai trung nhau
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 10, 2, 2), (2, 20, 0, 0)])

        # 4. Nut con co 2 nut cha
        @test_throws ArgumentError kiem_tra_dau_vao(1, [
            (1, 10, 2, 3),
            (2, 20, 0, 0),
            (3, 30, 2, 0) # Nut 2 vua la con cua 1 vua la con cua 3
        ])

        # 5. Nut goc co nut cha tro vao
        @test_throws ArgumentError kiem_tra_dau_vao(1, [
            (1, 10, 2, 0),
            (2, 20, 1, 0) # Nut 2 tro nguoc lai goc 1
        ])

        # 6. Cay khong lien thong (nut roi rac)
        @test_throws ArgumentError kiem_tra_dau_vao(1, [
            (1, 10, 0, 0),
            (2, 20, 0, 0) # Nut 2 khong toi duoc tu goc 1
        ])

        # 7. Cay rong nhung goc != 0
        @test_throws ArgumentError kiem_tra_dau_vao(1, Tuple{Int,Any,Int,Int}[])
    end

    @testset "T12 - Kiem tra yeu cau mo rong: Trung binh gia tri tung muc" begin
        # Kiem tra tren Vi du 1
        goc = 1
        nut = [(1, 10, 2, 3), (2, 20, 4, 0), (3, 30, 0, 0), (4, 40, 0, 0)]
        kq = giai_bai(goc, nut)
        @test kq.trung_binh == [10.0, 25.0, 40.0]

        # Kiem tra cay rong
        @test isempty(trung_binh_tung_muc(Vector{Vector{Any}}()))
    end

    @testset "T13 - Goc khac 1, bang nut dao thu tu, gia tri trung nhau" begin
        nut = [(4, 7, 0, 0), (2, 7, 1, 4), (1, 7, 0, 0), (3, 9, 2, 0)]
        kq = giai_bai(3, nut)
        @test kq.thu_tu_id == [3, 2, 1, 4]
        @test kq.cac_muc == [[9], [7], [7, 7]]
        @test kq.do_rong == [1, 1, 2]
        @test kq.rong_nhat == 2
        @test kq.muc == 2
        @test kq.trung_binh == [9.0, 7.0, 7.0]
    end

    @testset "T14 - Bien tren hop le n=100, cay day" begin
        nut = [(i, i, 0, i < 100 ? i + 1 : 0) for i in 1:100]
        kq = giai_bai(1, nut)
        @test kq.thu_tu_id == collect(1:100)
        @test kq.do_rong == ones(Int, 100)
        @test kq.rong_nhat == 1
        @test kq.muc == 0
        @test kq.max_queue_len == 1
        @test kq.so_nut_vao_queue == 100
        @test kq.so_nut_ra_queue == 100
    end

    @testset "T15 - Tu choi n=101 truoc khi duyet" begin
        nut = [(i, i, 0, i < 101 ? i + 1 : 0) for i in 1:101]
        @test_throws ArgumentError giai_bai(1, nut)
    end

    @testset "T16 - Tu choi ID trung lap" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, 2, 0), (1, 6, 0, 0)])
    end

    @testset "T17 - Tu choi con ngoai mien" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, 0, 2)])
    end

    @testset "T18 - Tu choi goc khong nguyen bang ArgumentError" begin
        @test_throws ArgumentError giai_bai(1.0, [(1, 5, 0, 0)])
    end

    @testset "T19 - Tu choi danh sach nut khong phai vector/tuple" begin
        @test_throws ArgumentError kiem_tra_dau_vao(0, nothing)
    end

    @testset "T20 - Tu choi ban ghi nut vo huong" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [42])
    end

    @testset "T21 - Tu choi bo nut thieu truong" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, 0)])
    end

    @testset "T22 - Tu choi bo nut thua truong" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, 0, 0, 0)])
    end

    @testset "T23 - Tu choi ID so thuc" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1.0, 5, 0, 0)])
    end

    @testset "T24 - Tu choi con khong nguyen" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, "0", 0)])
    end

    @testset "T25 - BigInt ID qua lon: ArgumentError, khong phai InexactError" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(big(10)^100, 5, 0, 0)])
    end

    @testset "T26 - BigInt con qua lon: ArgumentError, khong phai InexactError" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(1, 5, big(10)^100, 0)])
    end

    @testset "T27 - Tu choi gia tri NaN" begin
        @test_throws ArgumentError giai_bai(1, [(1, NaN, 0, 0)])
    end

    @testset "T28 - Tu choi gia tri vo cuc" begin
        @test_throws ArgumentError giai_bai(1, [(1, Inf, 0, 0)])
    end

    @testset "T29 - Tu choi so phuc theo hop dong gia tri so thuc/chuoi" begin
        @test_throws ArgumentError giai_bai(1, [(1, 1 + 2im, 0, 0)])
    end

    @testset "T30 - Bool khong duoc dung lam ID" begin
        @test_throws ArgumentError kiem_tra_dau_vao(1, [(true, 5, 0, 0)])
    end

    @testset "T31 - Tu choi gia tri nut khong phai so/chuoi" begin
        @test_throws ArgumentError giai_bai(1, [(1, [5], 0, 0)])
    end

    @testset "T32 - Cac lan goi doc lap, khong giu trang thai queue cu" begin
        nut = [(1, 10, 2, 3), (2, 20, 0, 0), (3, 30, 0, 0)]
        truoc = deepcopy(nut)
        a = giai_bai(1, nut)
        a.cac_muc[1][1] = -999
        b = giai_bai(1, nut)
        @test b.cac_muc == [[10], [20, 30]]
        @test b.thu_tu_id == [1, 2, 3]
        @test b.so_nut_vao_queue == 3
        @test b.so_nut_ra_queue == 3
        @test nut == truoc
    end

    @testset "T33 - Trung binh Int lon khong tran tong nguyen" begin
        lon = typemax(Int)
        kq = giai_bai(1, [(1, 0, 2, 3), (2, lon, 0, 0), (3, lon, 0, 0)])
        @test kq.trung_binh[2] == Float64(lon)
        @test isfinite(kq.trung_binh[2])
        @test kq.trung_binh[2] > 0
    end

    @testset "T34 - Trung binh Float64 lon khong tran tong thuc" begin
        kq = giai_bai(1, [(1, 0.0, 2, 3), (2, 1e308, 0, 0), (3, 1e308, 0, 0)])
        @test kq.trung_binh[2] ≈ 1e308
        @test isfinite(kq.trung_binh[2])
        @test trung_binh_tung_muc([[floatmax(Float64), floatmax(Float64)]])[1] == floatmax(Float64)
    end

    @testset "T35 - Muc chua chuoi khong co trung binh so" begin
        kq = giai_bai(1, [(1, "goc", 2, 3), (2, 1.5, 0, 0), (3, "la", 0, 0)])
        @test kq.cac_muc == [["goc"], [1.5, "la"]]
        @test kq.trung_binh == [nothing, nothing]
        @test kq.do_rong == [1, 2]
    end

    @testset "T36 - Tu choi chu trinh o thanh phan roi rac" begin
        nut = [(1, 5, 0, 0), (2, 6, 3, 0), (3, 7, 2, 0)]
        @test_throws ArgumentError kiem_tra_dau_vao(1, nut)
    end

    @testset "T37 - Tu choi so huu han vuot mien Float64" begin
        @test_throws ArgumentError giai_bai(1, [(1, big(10)^1000, 0, 0)])
    end

    @testset "T38 - Tu choi Bool trong gia tri va goc" begin
        @test_throws ArgumentError giai_bai(1, [(1, true, 0, 0)])
        @test_throws ArgumentError giai_bai(true, [(1, 5, 0, 0)])
    end

end
