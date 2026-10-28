# Lenh chay bang lan vet va khao sat 3 quy mo:
#   julia --startup-file=no scripts/trace_and_scales.jl

include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai
using Printf

function in_bang_lan_vet_vi_du_1()
    println("========================================================================================================================")
    println("BANG LAN VET TUNG BUOC THUAT TOAN DUYET CAY THEO MUC BANG HANG DOI (VI DU 1 - DE TAI DT084)")
    println("Cay nhi phan: goc=1; nut=[(1,10,2,3), (2,20,4,0), (3,30,0,0), (4,40,0,0)]")
    println("========================================================================================================================")
    @printf("%-6s | %-10s | %-6s | %-12s | %-6s | %-6s | %-25s | %-20s | %-12s\n",
            "Buoc", "Nut lay (u)", "Muc u", "Con them vao", "dau", "cuoi", "Hang doi cho (FIFO)", "cac_muc tich luy", "do_rong")
    println("-"^120)

    cay = khoi_tao_cay([(1,10,2,3), (2,20,4,0), (3,30,0,0), (4,40,0,0)])
    hang_id = zeros(Int, 4)
    hang_muc = zeros(Int, 4)
    dau, cuoi = 1, 1
    hang_id[1] = 1
    hang_muc[1] = 0

    cac_muc = Vector{Vector{Any}}()
    
    # Bước khởi tạo (Bước 0)
    fifo_str = "[(ID:1, M:0)]"
    @printf("%-6s | %-10s | %-6s | %-12s | %-6d | %-6d | %-25s | %-20s | %-12s\n",
            "0 (Init)", "-", "-", "Goc (1, M:0)", dau, cuoi, fifo_str, "[]", "[]")

    buoc = 0
    while dau <= cuoi
        buoc += 1
        u_id = hang_id[dau]
        muc_u = hang_muc[dau]
        dau += 1
        nut_u = cay[u_id]

        while length(cac_muc) <= muc_u
            push!(cac_muc, Any[])
        end
        push!(cac_muc[muc_u + 1], nut_u.gia_tri)

        them_con = String[]
        if nut_u.trai != 0
            cuoi += 1
            hang_id[cuoi] = nut_u.trai
            hang_muc[cuoi] = muc_u + 1
            push!(them_con, "T:$(nut_u.trai)")
        end
        if nut_u.phai != 0
            cuoi += 1
            hang_id[cuoi] = nut_u.phai
            hang_muc[cuoi] = muc_u + 1
            push!(them_con, "P:$(nut_u.phai)")
        end

        con_str = isempty(them_con) ? "Khong" : join(them_con, ", ")
        
        # Tạo chuỗi biểu diễn hàng đợi đang chờ
        cho_arr = String[]
        for k in dau:cuoi
            push!(cho_arr, "ID:$(hang_id[k])")
        end
        cho_str = isempty(cho_arr) ? "[Rong]" : "[" * join(cho_arr, ", ") * "]"
        muc_str = "[" * join([string(m) for m in cac_muc], ", ") * "]"
        dr_str = string([length(m) for m in cac_muc])

        nut_str = "ID:$(u_id) (gt:$(nut_u.gia_tri))"
        @printf("%-6d | %-10s | %-6d | %-12s | %-6d | %-6d | %-25s | %-20s | %-12s\n",
                buoc, nut_str, muc_u, con_str, dau, cuoi, cho_str, muc_str, dr_str)
    end
    println("="^120)
    println("Ket thuc: Hang doi rong (dau > cuoi). Tong so buoc lap = $buoc.")
    thong_tin = muc_rong_nhat(cac_muc)
    println("Ket qua cuoi: cac_muc = ", cac_muc)
    println("Do rong tung muc: ", do_rong(cac_muc))
    println("Do rong lon nhat: $(thong_tin.rong_nhat) tai Muc: $(thong_tin.muc)")
    println("========================================================================================================================\n")
end

function khao_sat_ba_quy_mo()
    println("========================================================================================================================")
    println("KHAO SAT THUC NGHIEM 3 QUY MO N = 3, N = 7, N = 31 (SO SANH CAY LECH VS CAY NHI PHAN DAY)")
    println("Phuong phap: dem so luot vao/ra queue va so nut dang cho lon nhat; khong do thoi gian.")
    println("Quy uoc: chieu cao tinh theo so canh tren duong dai nhat tu goc toi la.")
    println("========================================================================================================================")
    @printf("%-6s | %-16s | %-8s | %-10s | %-10s | %-14s | %-12s | %-12s\n",
            "Cỡ N", "Dang cay", "Chieu cao", "Vao Queue", "Ra Queue", "Queue Max (O)", "Rong nhat", "Muc rong nhat")
    println("-"^100)

    cac_co = [3, 7, 31]

    for n in cac_co
        # 1. Cây lệch phải hoàn toàn (dây xích)
        nut_lech = Tuple{Int,Any,Int,Int}[]
        for i in 1:n
            trai = 0
            phai = i < n ? i + 1 : 0
            push!(nut_lech, (i, i * 10, trai, phai))
        end
        kq_lech = giai_bai(1, nut_lech)
        @printf("%-6d | %-16s | %-8d | %-10d | %-10d | %-14d | %-12d | %-12s\n",
                n, "Day lech phai", n - 1, kq_lech.so_nut_vao_queue, kq_lech.so_nut_ra_queue, kq_lech.max_queue_len, kq_lech.rong_nhat, string(kq_lech.muc))

        # 2. Cây nhị phân đầy đủ (Full/Complete Binary Tree)
        nut_day = Tuple{Int,Any,Int,Int}[]
        for i in 1:n
            trai = 2 * i <= n ? 2 * i : 0
            phai = 2 * i + 1 <= n ? 2 * i + 1 : 0
            push!(nut_day, (i, i * 10, trai, phai))
        end
        kq_day = giai_bai(1, nut_day)
        h_day = floor(Int, log2(n))
        @printf("%-6d | %-16s | %-8d | %-10d | %-10d | %-14d | %-12d | %-12s\n",
                n, "Nhi phan day", h_day, kq_day.so_nut_vao_queue, kq_day.so_nut_ra_queue, kq_day.max_queue_len, kq_day.rong_nhat, string(kq_day.muc))
        println("-"^100)
    end
    println("NHAN XET KHAO SAT QUY MO:")
    println("1. Tong so luot vao va ra queue = 2*n. Ket hop phan tich moi buoc O(1), loi duyet ton O(n).")
    println("2. Dung luong queue cuc dai:")
    println("   - Cay lech: chi 1 nut dang cho. Mang queue trong code van cap phat n o, khong phai bo nho O(1).")
    println("   - Cac cay day trong bang: queue max=ceil(n/2) (n=31: 16 nut). Xau nhat O(n).")
    println("3. max_queue_len la so nut dang cho, khac so o da cap phat; queue va nhom ket qua deu dung O(n) bo nho.")
    println("========================================================================================================================\n")
end

if abspath(PROGRAM_FILE) == @__FILE__
    if isempty(ARGS)
        in_bang_lan_vet_vi_du_1()
        khao_sat_ba_quy_mo()
    elseif ARGS == ["--trace"]
        in_bang_lan_vet_vi_du_1()
    elseif ARGS == ["--scales"]
        khao_sat_ba_quy_mo()
    else
        println(stderr, "Cach dung: trace_and_scales.jl [--trace | --scales]")
        exit(1)
    end
end
