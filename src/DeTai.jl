module DeTai

export NutCay, khoi_tao_cay, kiem_tra_dau_vao, duyet_muc, do_rong, muc_rong_nhat, giai_bai, trung_binh_tung_muc

"""
    NutCay(id, gia_tri, trai, phai)

Cấu trúc biểu diễn một nút trong cây nhị phân:
- `id::Int`: Định danh nút (từ 1 đến n).
- `gia_tri::Any`: Số thực hữu hạn biểu diễn được bằng Float64 hoặc chuỗi.
- `trai::Int`: ID của nút con trái (0 nếu không có con trái).
- `phai::Int`: ID của nút con phải (0 nếu không có con phải).
"""
struct NutCay
    id::Int
    gia_tri::Any
    trai::Int
    phai::Int
end

"""
    kiem_tra_dau_vao(goc, nut)

Kiểm tra tính hợp lệ của dữ liệu đầu vào theo hợp đồng của đề tài DT084:
1. Số lượng nút n phải nằm trong khoảng 0..100.
2. Nếu n = 0 (cây rỗng): goc phải bằng 0 và danh sách nut phải rỗng.
3. Nếu n > 0:
   - Gốc goc phải nằm trong 1..n.
   - Giá trị là số thực hữu hạn biểu diễn được bằng Float64 hoặc chuỗi; không nhận Bool.
   - Mỗi bộ (id, gia_tri, trai, phai) phải có ID thuộc 1..n, các ID phải phân biệt và đủ từ 1 đến n.
   - Các chỉ số con trai, phai phải thuộc 0..n và không được trỏ vào chính nó (trai != id, phai != id).
   - Mỗi nút con chỉ có duy nhất một nút cha (bậc vào <= 1).
   - Nút gốc không được là con của bất kỳ nút nào (bậc vào = 0).
   - Cây phải liên thông và không có chu trình: toàn bộ n nút đều phải tới được từ gốc.
Ném ArgumentError nếu phát hiện vi phạm.
"""
function kiem_tra_dau_vao(goc, nut)
    (nut isa AbstractVector || nut isa Tuple) ||
        throw(ArgumentError("Danh sach nut phai la vector hoac tuple cac bo 4 phan tu"))
    (goc isa Integer && !(goc isa Bool)) ||
        throw(ArgumentError("ID nut goc phai la so nguyen, khong phai Bool"))
    n = length(nut)
    0 <= n <= 100 || throw(ArgumentError("So luong nut n=$n vuot qua pham vi cho phep (0..100)"))

    if n == 0
        goc == 0 || throw(ArgumentError("Cay rong (n=0) yeu cau goc phai bang 0, nhan duoc goc=$goc"))
        return true
    end

    1 <= goc <= n || throw(ArgumentError("ID nut goc goc=$goc nam ngoai pham vi hop le (1..$n)"))

    # ID thuộc 1..n nên dùng mảng trực tiếp: O(n), không phụ thuộc bảng băm.
    co_id = falses(n)
    bac_vao = zeros(Int, n)
    con_trai = zeros(Int, n)
    con_phai = zeros(Int, n)

    for item in nut
        (item isa Tuple || item isa AbstractVector) ||
            throw(ArgumentError("Moi nut phai la tuple hoac vector 4 phan tu"))
        length(item) == 4 || throw(ArgumentError("Moi nut phai la bo 4 phan tu (id, gia_tri, trai, phai)"))
        id, gia_tri, trai, phai = item

        all(x -> x isa Integer && !(x isa Bool), (id, trai, phai)) ||
            throw(ArgumentError("id, con trai va con phai phai la so nguyen, khong phai Bool"))

        # Kiểm miền trước Int(): số BigInt/UInt lớn phải bị từ chối bằng ArgumentError.
        1 <= id <= n || throw(ArgumentError("ID nut id=$id nam ngoai pham vi (1..$n)"))
        0 <= trai <= n || throw(ArgumentError("Chi so con trai trai=$trai nam ngoai 0..$n"))
        0 <= phai <= n || throw(ArgumentError("Chi so con phai phai=$phai nam ngoai 0..$n"))
        _kiem_tra_gia_tri(gia_tri)

        id_int = Int(id)
        trai_int = Int(trai)
        phai_int = Int(phai)

        co_id[id_int] && throw(ArgumentError("ID nut bi trung lap: $id_int"))
        co_id[id_int] = true
        con_trai[id_int] = trai_int
        con_phai[id_int] = phai_int

        trai_int != id_int || throw(ArgumentError("Nut $id_int khong the co con trai la chinh no (khuyen)"))
        phai_int != id_int || throw(ArgumentError("Nut $id_int khong the co con phai la chinh no (khuyen)"))

        if trai_int != 0 && phai_int != 0 && trai_int == phai_int
            throw(ArgumentError("Nut $id_int co con trai va con phai trung nhau: $trai_int"))
        end

        if trai_int != 0
            bac_vao[trai_int] += 1
            bac_vao[trai_int] <= 1 || throw(ArgumentError("Nut con $trai_int co nhieu hon mot nut cha"))
        end

        if phai_int != 0
            bac_vao[phai_int] += 1
            bac_vao[phai_int] <= 1 || throw(ArgumentError("Nut con $phai_int co nhieu hon mot nut cha"))
        end
    end

    all(co_id) || throw(ArgumentError("Danh sach nut khong du n=$n nut phan biet"))

    # Kiểm tra nút gốc không có cha
    goc_int = Int(goc)
    bac_vao[goc_int] == 0 || throw(ArgumentError("Nut goc goc=$goc khong duoc co nut cha (bac vao phai bang 0)"))

    # Kiểm tra tính liên thông từ gốc và không có chu trình
    da_tham = falses(n)
    hang_kt = zeros(Int, n)
    dau, cuoi = 1, 1
    hang_kt[1] = goc_int
    da_tham[goc_int] = true

    while dau <= cuoi
        u = hang_kt[dau]
        dau += 1
        t, p = con_trai[u], con_phai[u]
        if t != 0
            if da_tham[t]
                throw(ArgumentError("Phat hien chu trinh tai nut con $t"))
            end
            da_tham[t] = true
            cuoi += 1
            hang_kt[cuoi] = t
        end
        if p != 0
            if da_tham[p]
                throw(ArgumentError("Phat hien chu trinh tai nut con $p"))
            end
            da_tham[p] = true
            cuoi += 1
            hang_kt[cuoi] = p
        end
    end

    all(da_tham) || throw(ArgumentError("Ton tai nut khong the toi duoc tu goc (cay khong lien thong hoac co thanh phan roi rac)"))

    return true
end

function _kiem_tra_gia_tri(gia_tri)
    gia_tri isa AbstractString && return nothing
    (gia_tri isa Real && !(gia_tri isa Bool)) ||
        throw(ArgumentError("Gia tri nut phai la so thuc huu han hoac chuoi, khong phai Bool"))
    x = try
        Float64(gia_tri)
    catch
        throw(ArgumentError("Gia tri so phai bieu dien duoc bang Float64"))
    end
    isfinite(x) || throw(ArgumentError("Gia tri so phai huu han va nam trong mien Float64"))
    return nothing
end

"""
    khoi_tao_cay(nut)

Dựng mảng các đối tượng NutCay được lập chỉ mục theo ID từ 1 đến n.
Tiền điều kiện: bảng nút đã qua kiem_tra_dau_vao với gốc tương ứng.
"""
function khoi_tao_cay(nut)
    n = length(nut)
    n == 0 && return NutCay[]
    cay = Vector{NutCay}(undef, n)
    for item in nut
        id, gia_tri, trai, phai = item
        cay[Int(id)] = NutCay(Int(id), gia_tri, Int(trai), Int(phai))
    end
    return cay
end

"""
    duyet_muc(goc::Integer, nut)

Duyệt cây nhị phân theo từng mức (Level-Order Traversal) bằng hàng đợi FIFO.
Hàng đợi được cài đặt trực tiếp bằng mảng với hai con trỏ `dau` và `cuoi`.
Quy tắc:
- Gốc ở mức 0.
- Nút cha được lấy ra xử lý trước các nút con ở mức tiếp theo.
- Nút con được đưa vào hàng đợi theo thứ tự: trái trước, phải sau.
Trả về named tuple chứa:
- `cac_muc`: Dãy các nhóm giá trị cùng mức [[mức 0], [mức 1], ...].
- `day_theo_muc`: Dãy giá trị theo thứ tự duyệt hàng đợi.
- `thu_tu_id`: Dãy ID nút theo thứ tự duyệt.
- `so_nut_vao_queue`: Tổng số lượt đưa nút vào queue.
- `so_nut_ra_queue`: Tổng số lượt lấy nút khỏi queue.
- `max_queue_len`: Dung lượng hàng đợi lớn nhất trong suốt quá trình chạy.
"""
function duyet_muc(goc, nut)
    kiem_tra_dau_vao(goc, nut)
    n = length(nut)

    if n == 0
        return (;
            cac_muc = Vector{Vector{Any}}(),
            day_theo_muc = Any[],
            thu_tu_id = Int[],
            so_nut_vao_queue = 0,
            so_nut_ra_queue = 0,
            max_queue_len = 0
        )
    end

    cay = khoi_tao_cay(nut)

    # Cài đặt hàng đợi FIFO bằng mảng cấp phát trước và hai biến chỉ số dau, cuoi
    hang_id = zeros(Int, n)
    hang_muc = zeros(Int, n)
    dau = 1
    cuoi = 1

    hang_id[1] = Int(goc)
    hang_muc[1] = 0

    cac_muc = Vector{Vector{Any}}()
    day_theo_muc = Any[]
    thu_tu_id = Int[]

    so_nut_vao_queue = 1
    so_nut_ra_queue = 0
    max_queue_len = 1

    while dau <= cuoi
        # Cập nhật độ dài hàng đợi lớn nhất hiện tại
        do_dai_hien_tai = cuoi - dau + 1
        if do_dai_hien_tai > max_queue_len
            max_queue_len = do_dai_hien_tai
        end

        # Lấy nút ở đầu hàng đợi
        u_id = hang_id[dau]
        muc_u = hang_muc[dau]
        dau += 1
        so_nut_ra_queue += 1

        nut_u = cay[u_id]
        push!(day_theo_muc, nut_u.gia_tri)
        push!(thu_tu_id, u_id)

        # Mở rộng danh sách các mức nếu cần (mức 0 ứng với cac_muc[1])
        while length(cac_muc) <= muc_u
            push!(cac_muc, Any[])
        end
        push!(cac_muc[muc_u + 1], nut_u.gia_tri)

        # Đưa nút con trái vào hàng đợi trước (nếu tồn tại)
        if nut_u.trai != 0
            cuoi += 1
            hang_id[cuoi] = nut_u.trai
            hang_muc[cuoi] = muc_u + 1
            so_nut_vao_queue += 1
        end

        # Đưa nút con phải vào hàng đợi sau (nếu tồn tại)
        if nut_u.phai != 0
            cuoi += 1
            hang_id[cuoi] = nut_u.phai
            hang_muc[cuoi] = muc_u + 1
            so_nut_vao_queue += 1
        end
    end

    return (;
        cac_muc,
        day_theo_muc,
        thu_tu_id,
        so_nut_vao_queue,
        so_nut_ra_queue,
        max_queue_len
    )
end

"""
    do_rong(cac_muc)

Xác định độ rộng (số lượng nút) của từng mức.
Trả về mảng số nguyên biểu thị số nút tại mức 0, mức 1, ...
"""
function do_rong(cac_muc)
    return [length(m) for m in cac_muc]
end

"""
    muc_rong_nhat(cac_muc)

Xác định độ rộng lớn nhất và mức đầu tiên đạt độ rộng đó.
Quy ước:
- Gốc ở mức 0.
- Nếu nhiều mức cùng đạt độ rộng lớn nhất, chọn mức đầu tiên (mức nhỏ nhất).
- Nếu cây rỗng (cac_muc rỗng): trả về (rong_nhat = 0, muc = nothing).
"""
function muc_rong_nhat(cac_muc)
    if isempty(cac_muc)
        return (rong_nhat = 0, muc = nothing)
    end
    ds_rong = do_rong(cac_muc)
    max_w = maximum(ds_rong)
    idx = findfirst(==(max_w), ds_rong) # Chỉ số 1-based trong Julia
    muc_dau_tien = idx - 1              # Quy ước mức 0-indexed theo phiếu
    return (rong_nhat = max_w, muc = muc_dau_tien)
end

"""
    trung_binh_tung_muc(cac_muc)

Yêu cầu thêm tùy chọn theo phiếu DT084:
Tính giá trị trung bình cộng các nút ở từng mức dưới dạng Float64.
Mức chứa chuỗi hoặc không có nút trả về nothing vì không có trung bình số.
Cây rỗng trả về Float64[]. Số được đổi kiểu trước khi cộng để tránh tràn Int.
"""
function trung_binh_tung_muc(cac_muc)
    isempty(cac_muc) && return Float64[]
    kq = Union{Nothing,Float64}[]
    for m in cac_muc
        (m isa AbstractVector || m isa Tuple) ||
            throw(ArgumentError("Moi muc phai la mot danh sach gia tri"))
        foreach(_kiem_tra_gia_tri, m)
        if isempty(m)
            push!(kq, nothing)
        elseif all(x -> x isa Real, m)
            # Đổi sang Float64 và chia trước khi cộng để tránh tràn tổng trung gian.
            tb = sum(x -> Float64(x) / length(m), m)
            if !isfinite(tb)
                # Làm tròn sát floatmax có thể gây tràn; tổng chuẩn hóa vẫn hữu hạn.
                ti_le = maximum(x -> abs(Float64(x)), m)
                tb_chuan = sum(x -> (Float64(x) / ti_le) / length(m), m)
                tb = clamp(tb_chuan, -1.0, 1.0) * ti_le
            end
            push!(kq, tb)
        else
            push!(kq, nothing)
        end
    end
    return kq
end

"""
    giai_bai(goc, nut)

Hàm thực thi toàn bộ quy trình của đề tài DT084:
1. Kiểm tra tính hợp lệ dữ liệu.
2. Duyệt cây theo mức bằng hàng đợi FIFO.
3. Xác định độ rộng từng mức.
4. Tìm độ rộng lớn nhất và mức đầu tiên đạt độ rộng đó.
5. Kiểm tra các bất biến cấu trúc (invariants).
"""
function giai_bai(goc, nut)
    ket_qua_duyet = duyet_muc(goc, nut)
    cac_muc = ket_qua_duyet.cac_muc
    ds_rong = do_rong(cac_muc)
    thong_tin_rong = muc_rong_nhat(cac_muc)

    n = length(nut)
    # Kiểm tra bất biến:
    # 1. Tổng độ rộng các mức phải bằng đúng số nút n
    @assert sum(ds_rong; init=0) == n "Bat bien tong do rong cac muc phai bang $n"
    # 2. Chiều dài dãy duyệt phẳng phải bằng n
    @assert length(ket_qua_duyet.day_theo_muc) == n "Bat bien so phan tu duyet phai bang $n"
    # 3. Mỗi nút vào và ra hàng đợi đúng 1 lần
    if n > 0
        @assert ket_qua_duyet.so_nut_vao_queue == n "Bat bien vao queue phai dung $n"
        @assert ket_qua_duyet.so_nut_ra_queue == n "Bat bien ra queue phai dung $n"
    end

    return (;
        goc,
        nut,
        n,
        cac_muc,
        day_theo_muc = ket_qua_duyet.day_theo_muc,
        thu_tu_id = ket_qua_duyet.thu_tu_id,
        do_rong = ds_rong,
        rong_nhat = thong_tin_rong.rong_nhat,
        muc = thong_tin_rong.muc,
        max_queue_len = ket_qua_duyet.max_queue_len,
        so_nut_vao_queue = ket_qua_duyet.so_nut_vao_queue,
        so_nut_ra_queue = ket_qua_duyet.so_nut_ra_queue,
        trung_binh = trung_binh_tung_muc(cac_muc)
    )
end

end # module DeTai
