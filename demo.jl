
include(joinpath(@__DIR__, "src", "DeTai.jl"))
using .DeTai
using Printf

function in_ket_qua(goc, nut; ten_ca="KET QUA DUYET CAY")
    println("================================================================================")
    println("DT084 - DUYET CAY THEO MUC VA XAC DINH DO RONG TUNG MUC")
    println("Ca: $ten_ca")
    println("Input: goc=$goc; n=$(length(nut))")
    println("Danh sach nut: $nut")
    println("--------------------------------------------------------------------------------")

    kq = giai_bai(goc, nut)

    println("Duyet theo thu tu hang doi FIFO:")
    println("  - Thu tu ID nut   : ", join(kq.thu_tu_id, " -> "))
    println("  - Thu tu gia tri  : ", join(kq.day_theo_muc, " -> "))
    println("\nPhan nhom theo tung muc (cac_muc):")
    if isempty(kq.cac_muc)
        println("  (Cay rong: khong co muc nao de in)")
    else
        for (i, m) in enumerate(kq.cac_muc)
            muc_idx = i - 1
            @printf("  * Muc %2d (do rong %2d): %s\n", muc_idx, length(m), string(m))
        end
    end

    println("\nThong ke do rong va muc rong nhat:")
    println("  - Do rong tung muc : ", kq.do_rong)
    println("  - Do rong lon nhat : ", kq.rong_nhat)
    println("  - Muc dau tien dat : ", kq.muc === nothing ? "Khong ton tai (cay rong)" : kq.muc)
    println("  - Trung binh muc   : ", kq.trung_binh)

    println("\nThong so van hanh hang doi (Kiem chung chi phi):")
    println("  - So luot nut vao queue : ", kq.so_nut_vao_queue)
    println("  - So luot nut ra queue  : ", kq.so_nut_ra_queue)
    println("  - Dung luong queue toi da: ", kq.max_queue_len)
    println("================================================================================\n")
    return nothing
end

function doc_dong(io::IO)
    eof(io) && throw(ArgumentError("Thieu du lieu: chua nhap du cac dong cua cay"))
    return strip(readline(io))
end

function doc_so_nguyen(token, ten)
    gia_tri = tryparse(Int, token)
    gia_tri === nothing && throw(ArgumentError("$ten phai la so nguyen trong mien Int"))
    return gia_tri
end

function doc_gia_tri(token)
    # Giữ số nguyên lớn, không làm tròn ID hoặc số nguyên thành số thực.
    so_nguyen = tryparse(BigInt, token)
    if so_nguyen !== nothing
        return typemin(Int) <= so_nguyen <= typemax(Int) ? Int(so_nguyen) : so_nguyen
    end
    so_thuc = tryparse(Float64, token)
    if so_thuc !== nothing
        isfinite(so_thuc) || throw(ArgumentError("Gia tri so phai huu han (khong NaN/Inf)"))
        return so_thuc
    end
    return String(token)
end

"""Đọc n, gốc và đủ n dòng nút; kiểm tra miền n trước khi yêu cầu nhập nút."""
function doc_cay(io::IO=stdin; out::IO=stdout)
    println(out, "Nhap so luong nut n va id goc (vi du: 4 1):")
    raw = split(doc_dong(io))
    length(raw) == 2 || throw(ArgumentError("Can nhap dung 2 so nguyen: n va goc"))
    n = doc_so_nguyen(raw[1], "n")
    goc = doc_so_nguyen(raw[2], "goc")
    0 <= n <= 100 || throw(ArgumentError("So luong nut n phai thuoc 0..100"))
    (n == 0 ? goc == 0 : 1 <= goc <= n) || throw(ArgumentError("Goc khong phu hop voi so luong nut"))

    nut = Tuple{Int,Any,Int,Int}[]
    if n > 0
        println(out, "Nhap moi nut: id gia_tri trai phai (0 la con rong).")
        println(out, "Gia tri la so huu han hoac chuoi khong co khoang trang.")
    end
    for i in 1:n
        println(out, "Nut thu $i:")
        raw = split(doc_dong(io))
        length(raw) == 4 || throw(ArgumentError("Moi dong can dung 4 gia tri: id gia_tri trai phai"))
        id = doc_so_nguyen(raw[1], "id")
        trai = doc_so_nguyen(raw[3], "trai")
        phai = doc_so_nguyen(raw[4], "phai")
        push!(nut, (id, doc_gia_tri(raw[2]), trai, phai))
    end
    kiem_tra_dau_vao(goc, nut)
    return (; goc, nut)
end

function nhap_ban_phim()
    println("=== NHAP DU LIEU CAY NHI PHAN TU BAN PHIM ===")
    cay = doc_cay()
    in_ket_qua(cay.goc, cay.nut; ten_ca="NHAP TU BAN PHIM")
end

function minh_hoa_du_lieu_sai()
    println("================================================================================")
    println("DT084 - MINH HOA TU CHOI DU LIEU KHONG HOP LE (CA LOI A08)")
    println("Input loi: nut con tro tao chu trinh (1 -> con 2; 2 -> con 1)")
    println("goc = 1; nut = [(1, 10, 2, 0), (2, 20, 1, 0)]")
    println("Mong doi: Tu choi cay co chu trinh (goc bi tro nguoc, co cha).")
    println("--------------------------------------------------------------------------------")
    try
        giai_bai(1, [(1, 10, 2, 0), (2, 20, 1, 0)])
    catch loi
        if loi isa ArgumentError
            println("DA TU CHOI DU LIEU THANH CONG!")
            println("Thong bao loi: ", sprint(showerror, loi))
            println("KET QUA MINH HOA A08: PASS - input khong hop le da bi tu choi.")
            println("================================================================================\n")
            return nothing
        end
        rethrow()
    end
    error("LOI HE THONG: Chuong trinh khong bat duoc cay co chu trinh!")
end

const CA_DEMO = Dict(
    1 => (goc=1, nut=[(1, 10, 2, 3), (2, 20, 4, 0), (3, 30, 0, 0), (4, 40, 0, 0)], ten="A01_ViDu1_PhieuGiao"),
    2 => (goc=1, nut=[(1, 8, 0, 0)], ten="A02_ViDu2_PhieuGiao"),
    3 => (goc=1, nut=[(1, 1, 2, 3), (2, 2, 4, 5), (3, 3, 6, 7), (4, 4, 0, 0), (5, 5, 0, 0), (6, 6, 0, 0), (7, 7, 0, 0)], ten="A03_CayDay7Nut"),
    4 => (goc=1, nut=[(1, 10, 2, 3), (2, 20, 4, 0), (3, 30, 0, 5), (4, 40, 0, 0), (5, 50, 0, 0)], ten="A04_HoaDoRong_ChonMucNhoNhat"),
    5 => (goc=0, nut=Tuple{Int,Any,Int,Int}[], ten="A05_CayRong"),
    6 => (goc=1, nut=[(1, 10, 0, 2), (2, 20, 0, 3), (3, 30, 0, 4), (4, 40, 0, 0)], ten="A06_DayPhai4Nut"),
    7 => (goc=1, nut=[(1, 100, 2, 3), (2, 200, 0, 0), (3, 300, 0, 0)], ten="A07_GocHaiLa"),
)

function main_demo(args=ARGS)
    if args == ["--nhap"]
        nhap_ban_phim()
    elseif length(args) == 1 && startswith(only(args), "--ca=")
        ca_str = only(args)
        id_ca = tryparse(Int, replace(ca_str, "--ca=" => ""))
        if id_ca !== nothing && id_ca in 1:7
            c = CA_DEMO[id_ca]
            in_ket_qua(c.goc, c.nut; ten_ca=c.ten)
        elseif id_ca == 8
            minh_hoa_du_lieu_sai()
        else
            throw(ArgumentError("Tham so khong hop le: Chon --ca=1 den --ca=8"))
        end
    elseif isempty(args)
        println("CHAY MAC DINH HAI VI DU TREN PHIEU GIAO DE TAI DT084:")
        c1 = CA_DEMO[1]
        in_ket_qua(c1.goc, c1.nut; ten_ca=c1.ten)
        c2 = CA_DEMO[2]
        in_ket_qua(c2.goc, c2.nut; ten_ca=c2.ten)
    else
        throw(ArgumentError("Cach dung: demo.jl [--ca=1..8 | --nhap]"))
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    try
        main_demo()
    catch loi
        loi isa InterruptException && rethrow()
        if loi isa ArgumentError
            println(stderr, "DU LIEU/THAM SO KHONG HOP LE: ", sprint(showerror, loi))
            exit(1)
        end
        rethrow()
    end
end

nothing
