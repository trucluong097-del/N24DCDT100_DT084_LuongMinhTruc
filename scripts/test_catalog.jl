# Các ID này trùng bộ runtests.jl; đây là bảng bằng chứng, không cộng thành ca mới.
include(joinpath(@__DIR__, "..", "src", "DeTai.jl"))
using .DeTai

function in_ca(id, goc, nut, expected)
    println("\n", id, " | goc=", goc, " | nut=", nut)
    println("Expected (viet truoc tu so do cay): ", expected)
    kq = giai_bai(goc, nut)
    actual = NamedTuple{keys(expected)}(Tuple(getproperty(kq, k) for k in keys(expected)))
    println("Actual: ", actual)
    dat = actual == expected
    println("Ket qua: ", dat ? "PASS" : "FAIL")
    dat || error("$id sai expected")
end

println("DT084 - BANG DOI CHIEU 12 CA DA CO TRONG BO TEST T01..T38")
in_ca("T01", 1, [(1,10,2,3),(2,20,4,0),(3,30,0,0),(4,40,0,0)],
      (cac_muc=[[10],[20,30],[40]], do_rong=[1,2,1], rong_nhat=2, muc=1))
in_ca("T02", 1, [(1,8,0,0)], (cac_muc=[[8]], do_rong=[1], rong_nhat=1, muc=0))
in_ca("T03", 0, [], (cac_muc=[], do_rong=[], rong_nhat=0, muc=nothing))
in_ca("T04", 1, [(1,100,2,3),(2,200,0,0),(3,300,0,0)],
      (cac_muc=[[100],[200,300]], do_rong=[1,2], rong_nhat=2, muc=1))
in_ca("T05", 1, [(1,10,0,2),(2,20,0,3),(3,30,0,4),(4,40,0,0)],
      (cac_muc=[[10],[20],[30],[40]], do_rong=[1,1,1,1], rong_nhat=1, muc=0))
in_ca("T06", 1, [(1,1,2,3),(2,2,4,5),(3,3,6,7),(4,4,0,0),(5,5,0,0),(6,6,0,0),(7,7,0,0)],
      (cac_muc=[[1],[2,3],[4,5,6,7]], do_rong=[1,2,4], rong_nhat=4, muc=2))
in_ca("T07", 1, [(1,"A",2,0),(2,"B",3,0),(3,"C",4,0),(4,"D",0,0)],
      (cac_muc=[["A"],["B"],["C"],["D"]], do_rong=[1,1,1,1], rong_nhat=1, muc=0))
in_ca("T08", 1, [(1,10,2,0),(2,20,0,3),(3,30,4,0),(4,40,0,0)],
      (cac_muc=[[10],[20],[30],[40]], do_rong=[1,1,1,1], rong_nhat=1, muc=0))
in_ca("T09", 1, [(1,1,2,3),(2,2,4,0),(3,3,0,5),(4,4,6,0),(5,5,0,7),(6,6,0,0),(7,7,0,0)],
      (cac_muc=[[1],[2,3],[4,5],[6,7]], do_rong=[1,2,2,2], rong_nhat=2, muc=1))
nut15 = [(i,i,2*i <= 15 ? 2*i : 0,2*i+1 <= 15 ? 2*i+1 : 0) for i in 1:15]
in_ca("T10", 1, nut15, (do_rong=[1,2,4,8], rong_nhat=8, muc=3, max_queue_len=8))
in_ca("T13", 3, [(4,7,0,0),(2,7,1,4),(1,7,0,0),(3,9,2,0)],
      (thu_tu_id=[3,2,1,4], cac_muc=[[9],[7],[7,7]], do_rong=[1,1,2], rong_nhat=2, muc=2))

let nut_loi = [(1,10,2,0),(2,20,1,0)]
    println("\nT11.5 | goc=1 | nut=", nut_loi)
    println("Expected: ArgumentError - goc co cha, cay co chu trinh")
    bi_tu_choi = false
    try
        giai_bai(1, nut_loi)
    catch loi
        loi isa ArgumentError || rethrow()
        bi_tu_choi = true
        println("Actual: ", sprint(showerror, loi))
    end
    println("Ket qua: ", bi_tu_choi ? "PASS" : "FAIL")
    bi_tu_choi || error("T11.5 phai bi tu choi")
end
println("\nTONG KET BANG DOI CHIEU: 12/12 ca PASS; so phep kiem Test.jl ghi rieng trong runtests.jl.")
