# ==============================================================================
# MENU DIEU KHIEN VA GIAO DIEN TUONG TAC DE TAI DT084
# Sinh vien: Luong Minh Truc - MSSV: N24DCDT100 - Lop: D24CQDT01-N
# Hoc phan : Cau truc du lieu va giai thuat (INT13185 - Nhom 03)
# ==============================================================================

include(joinpath(@__DIR__, "demo.jl"))

function hien_thi_menu()
    println("\n" * "="^80)
    println("      HE THONG DIEU KHIEN CHUONG TRINH DE TAI DT084 (JULIA CLI)")
    println("   De tai: Duyet cay theo muc va xac dinh do rong tung muc bang Queue")
    println("   Sinh vien: Luong Minh Truc | MSSV: N24DCDT100 | Lop: D24CQDT01-N")
    println("="^80)
    println(" [1] Chay Vi du 1 tren phieu giao  (A01 - Cay 4 nut)")
    println(" [2] Chay Vi du 2 tren phieu giao  (A02 - Cay 1 nut goc)")
    println(" [3] Chay Ca tu thiet ke 1         (A03 - Cay nhi phan day du 7 nut)")
    println(" [4] Chay Ca tu thiet ke 2         (A04 - Hoa do rong -> Chon muc nho nhat)")
    println(" [5] Chay Ca bien 1 (Cay rong)     (A05 - n=0, goc=0)")
    println(" [6] Chay Ca bien 2 (Cay lech)     (A06 - Cay day lech phai 4 nut)")
    println(" [7] Chay Ca bien 3 (Goc 2 la)     (A07 - Cay 3 nut)")
    println(" [8] Chay Ca tu choi du lieu sai   (A08 - Phat hien chu trinh/khuyen)")
    println("--------------------------------------------------------------------------------")
    println(" [9] Chay bo kiem thu thuat toan va nhap lieu (A09)")
    println(" [10] Xuat Bang truy vet tung buoc   (Phuc vu Chuong 3 Bao cao)")
    println(" [11] Xuat Khao sat 3 quy mo cay     (Phuc vu Chuong 4 Bao cao)")
    println(" [12] Nhap cay tuy y tu ban phim    (Phuc vu van dap truc tiep truoc GV)")
    println(" [0] Thoat chuong trinh")
    println("="^80)
    print("Vui long nhap lua chon cua ban (0..12): ")
end

function chay_tep(duong_dan, args=String[])
    # Chạy tiến trình riêng để không nạp lại module DeTai trong phiên menu.
    run(`$(Base.julia_cmd()) --startup-file=no --history-file=no $duong_dan $args`)
end

function chay_menu()
    while true
        hien_thi_menu()
        eof(stdin) && break
        nhap = readline()
        lua_chon = tryparse(Int, strip(nhap))

        if lua_chon === nothing
            println("\n[!] Lua chon khong hop le, vui long nhap so tu 0 den 12.")
        elseif lua_chon == 0
            println("\nCam on thay va ban da su dung chuong trinh! Tam biet.")
            break
        else
            try
                if lua_chon in 1:7
                    c = CA_DEMO[lua_chon]
                    in_ket_qua(c.goc, c.nut; ten_ca=c.ten)
                elseif lua_chon == 8
                    minh_hoa_du_lieu_sai()
                elseif lua_chon == 9
                    chay_tep(joinpath(@__DIR__, "test", "runtests.jl"))
                    chay_tep(joinpath(@__DIR__, "test", "input_tests.jl"))
                elseif lua_chon == 10
                    chay_tep(joinpath(@__DIR__, "scripts", "trace_and_scales.jl"), ["--trace"])
                elseif lua_chon == 11
                    chay_tep(joinpath(@__DIR__, "scripts", "trace_and_scales.jl"), ["--scales"])
                elseif lua_chon == 12
                    nhap_ban_phim()
                else
                    println("\n[!] Lua chon ngoai pham vi (0..12).")
                end
            catch loi
                loi isa InterruptException && rethrow()
                if loi isa ArgumentError || loi isa ProcessFailedException
                    println("\n[!] ", sprint(showerror, loi))
                    println("Ban co the chon lai chuc nang hoac nhap lai du lieu.")
                else
                    rethrow()
                end
            end
        end

        print("\nNhan phim [Enter] de quay lai menu chinh...")
        eof(stdin) && break
        readline()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    chay_menu()
end
