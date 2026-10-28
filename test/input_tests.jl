using Test
include(joinpath(@__DIR__, "..", "demo.jl"))

doc_thu(s) = doc_cay(IOBuffer(s); out=devnull)

@testset "Nhap du lieu - 16 ca doc lap" begin
    @testset "I01 - Tu choi n am truoc khi doc nut" begin
        @test_throws ArgumentError doc_thu("-1 0\n")
    end
    @testset "I02 - Tu choi n vuot 100 ngay lap tuc" begin
        @test_throws ArgumentError doc_thu("101 1\n")
    end
    @testset "I03 - Cay rong dung quy uoc" begin
        cay = doc_thu("0 0\n")
        @test cay.goc == 0 && isempty(cay.nut)
    end
    @testset "I04 - Cay rong sai goc" begin
        @test_throws ArgumentError doc_thu("0 1\n")
    end
    @testset "I05 - Thieu dong nut" begin
        @test_throws ArgumentError doc_thu("2 1\n1 10 2 0\n")
    end
    @testset "I06 - Header sai so truong" begin
        @test_throws ArgumentError doc_thu("1 1 7\n")
    end
    @testset "I07 - n khong nguyen" begin
        @test_throws ArgumentError doc_thu("1.5 1\n")
    end
    @testset "I08 - Nut thieu truong" begin
        @test_throws ArgumentError doc_thu("1 1\n1 9 0\n")
    end
    @testset "I09 - ID khong nguyen" begin
        @test_throws ArgumentError doc_thu("1 1\n1.2 9 0 0\n")
    end
    @testset "I10 - Gia tri so thuc" begin
        cay = doc_thu("1 1\n1 2.5 0 0\n")
        @test giai_bai(cay.goc, cay.nut).trung_binh == [2.5]
    end
    @testset "I11 - Gia tri chuoi" begin
        cay = doc_thu("1 1\n1 Hoa 0 0\n")
        @test giai_bai(cay.goc, cay.nut).day_theo_muc == ["Hoa"]
    end
    @testset "I12 - Tu choi gia tri vo han" begin
        @test_throws ArgumentError doc_thu("1 1\n1 Inf 0 0\n")
    end
    @testset "I13 - Goc khac 1, thu tu dong dao" begin
        cay = doc_thu("3 2\n3 30 0 0\n2 20 1 3\n1 10 0 0\n")
        @test giai_bai(cay.goc, cay.nut).day_theo_muc == [20, 10, 30]
    end
    @testset "I14 - Tu choi chu trinh" begin
        @test_throws ArgumentError doc_thu("2 1\n1 10 2 0\n2 20 1 0\n")
    end
    @testset "I15 - So nguyen lon khong bi lam tron khi doc" begin
        cay = doc_thu("1 1\n1 9223372036854775808 0 0\n")
        @test cay.nut[1][2] == big"9223372036854775808"
    end
    @testset "I16 - Tham so demo sai" begin
        @test_throws ArgumentError main_demo(["--ca=abc"])
        @test_throws ArgumentError main_demo(["--nhap", "--ca=1"])
        @test_throws ArgumentError main_demo(["--ca=9"])
    end
end
