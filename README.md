# DT084 — Duyệt cây theo mức và xác định độ rộng từng mức

- Sinh viên: **Lương Minh Trực**, MSSV **N24DCDT100**, lớp **D24CQDT01-N**.
- Học phần: Cấu trúc dữ liệu và giải thuật — **INT13185, nhóm 03**.
- Giảng viên: **Hồ Nhựt Minh**.
- Căn cứ: Chương 7, mục 7.3.2; trang in 165, trang PDF 177 giáo trình INT1306.
- Chương trình chính dùng **Julia**, đã chạy kiểm tra bằng **Julia 1.12.6**.
- Chỉ dùng thư viện chuẩn `Test`, `Printf`; không cần cài gói hoặc dữ liệu ngoài.

## 1. Chạy chương trình

Mở PowerShell tại thư mục mã nguồn, chạy toàn bộ demo, test, bảng đối chiếu, truy vết và khảo sát:

```powershell
.\Run_all.ps1
```

Script tìm Julia trên PATH hoặc trong thư mục Juliaup của người dùng. Có thể chỉ định đường dẫn chính xác:

```powershell
.\Run_all.ps1 -Julia 'C:\duong_dan_thuc_te\bin\julia.exe'
```

Menu tương tác:

```powershell
julia --startup-file=no menu.jl
```

Các lệnh riêng (nếu chưa có Julia trên PATH, thay `julia` bằng `& 'DUONG_DAN_JULIA_EXE'`):

```powershell
julia --startup-file=no demo.jl                  # Hai ví dụ trên phiếu
julia --startup-file=no demo.jl --ca=1           # Ví dụ 1 riêng
julia --startup-file=no demo.jl --ca=2           # Ví dụ 2 riêng
julia --startup-file=no demo.jl --nhap           # Nhập dữ liệu mới
julia --startup-file=no test/runtests.jl         # Kiểm thử thuật toán
julia --startup-file=no test/input_tests.jl      # Kiểm thử nhập liệu
julia --startup-file=no scripts/test_catalog.jl # Input / expected / actual / PASS
julia --startup-file=no scripts/trace_and_scales.jl
julia --startup-file=no scripts/trace_and_scales.jl --trace
julia --startup-file=no scripts/trace_and_scales.jl --scales
```

Dữ liệu/tham số sai trả thông báo và mã thoát khác 0. A08 minh họa việc từ chối input sai đúng thiết kế nên trả mã 0. Menu cho chọn lại sau lỗi nhập liệu và chạy test trong tiến trình riêng để không nạp lại module.

## 2. Hợp đồng dữ liệu

Input là `goc` và danh sách bộ `(id, gia_tri, trai, phai)`:

- `0 <= n <= 100`; ID phân biệt, bao phủ `1..n`. Các dòng có thể xáo thứ tự.
- Con thuộc `0..n`; `0` là con rỗng. Gốc thuộc `1..n` khi cây có nút.
- Cây rỗng dùng `goc=0` và danh sách rỗng.
- Một cây liên thông từ gốc; không chu trình, khuyên, con trùng hoặc nhiều liên kết cha.
- Giá trị là số thực hữu hạn biểu diễn được bằng `Float64` hoặc chuỗi; không nhận Bool, số phức, NaN, vô cực. Nút khác ID có thể trùng giá trị.
- Đưa con trái vào queue trước con phải; gốc ở mức **0**.

Output gồm dãy ID, dãy giá trị, `cac_muc`, độ rộng từng mức, độ rộng lớn nhất và mức đầu tiên đạt độ rộng đó. Cây rỗng trả rộng nhất `0`, mức `nothing`. Có bộ đếm lượt vào/ra queue và số nút đang chờ lớn nhất.

Phần mở rộng tính trung bình dạng Float64, tránh tràn tổng trung gian. Mức chứa chuỗi trả `nothing`; dãy kết quả vẫn giữ giá trị gốc.

Nhập bàn phím: dòng đầu `n goc`, sau đó đủ `n` dòng `id gia_tri trai phai`. Giá trị mỗi dòng là số hoặc chuỗi không có khoảng trắng. Miền n và gốc được kiểm trước khi yêu cầu nhập nút.

### Ví dụ 1 trên phiếu

```text
4 1
1 10 2 3
2 20 4 0
3 30 0 0
4 40 0 0
```

Kỳ vọng: `cac_muc=[[10],[20,30],[40]]`, dãy `[10,20,30,40]`, độ rộng `[1,2,1]`, rộng nhất `2` tại mức `1`.

### Ví dụ 2 trên phiếu

```text
1 1
1 8 0 0
```

Kỳ vọng: `cac_muc=[[8]]`, rộng nhất `1`, mức `0`. Cây rỗng chỉ nhập `0 0`.

## 3. Tệp chương trình và demo

| Tệp | Vai trò |
|---|---|
| `src/DeTai.jl` | Validator, dựng cây, FIFO bằng mảng/hai chỉ số, duyệt mức, độ rộng, trung bình |
| `demo.jl` | A01–A08, đọc input và in kết quả |
| `menu.jl` | Menu demo, test, truy vết, khảo sát, nhập cây |
| `test/runtests.jl` | T01–T38: chức năng, biên, validator, hồi quy |
| `test/input_tests.jl` | I01–I16: nhập bàn phím và tham số |
| `scripts/test_catalog.jl` | In 12 ca đã có trong test với input/expected/actual/PASS |
| `scripts/trace_and_scales.jl` | Truy vết ví dụ 1, khảo sát 3–7–31 nút |
| `Giao_dien_truc_quan.html` | Mô phỏng JavaScript độc lập trong trình duyệt |
| `test/gui_tests.cjs` | Kiểm tra logic HTML bằng Node, tùy chọn |
| `docs/logs/` | Nhật ký chạy thật |
| `docs/anh_ket_qua/` | Nơi lưu ảnh A01–A11 sau khi tự chụp |

Chọn `demo.jl --ca=k`:

| k | Nội dung |
|---|---|
| 1 | A01: ví dụ 1 trên phiếu |
| 2 | A02: ví dụ 2 trên phiếu |
| 3 | A03: cây đầy 7 nút |
| 4 | A04: hòa độ rộng, chọn mức đầu tiên |
| 5 | A05: cây rỗng |
| 6 | A06: cây dây phải 4 nút |
| 7 | A07: gốc có hai lá |
| 8 | A08: từ chối cây có chu trình/gốc có cha |

## 4. Kiểm thử và độ phức tạp

Đã chạy bằng Julia 1.12.6:

- T01–T38: **38 nhóm ca có ID, 121/121 phép kiểm đạt**. T11 chứa bảy input validator; số nhóm ID không đồng nghĩa số input hoặc số assert.
- I01–I16: **16 nhóm ca có ID, 18/18 phép kiểm đạt**.
- Bảng đối chiếu: **12/12 ca đạt**, lấy lại ID trong bộ T; không cộng thành ca mới.
- GUI: **24/24 ca đạt** bằng Node với mô hình DOM, chưa kiểm bố cục trình duyệt.
- A01–A08, bảng truy vết và khảo sát đều chạy thành công. Xem `docs/logs/`.

Hai ví dụ và đủ năm ca trên phiếu nằm trong T01–T06. Có thêm gốc khác 1, bảng nút xáo thứ tự, giá trị trùng/chuỗi, giới hạn 100 nút, input sai, trạng thái giữa các lần gọi và trung bình số lớn. Expected chính viết từ sơ đồ cây, không dùng lại thuật toán tạo đáp án.

FIFO xử lý các mức không giảm; nút con có mức cha cộng một, trái trước phải. Mỗi nút vào/ra đúng một lần. Tổng độ rộng bằng n; `findfirst` giữ mức nhỏ nhất khi hòa.

Validator dùng mảng theo ID và duyệt liên thông: **O(n)** thời gian, bộ nhớ. Dựng cây, lõi duyệt, độ rộng và trung bình cũng O(n), giả sử chi phí thao tác mỗi giá trị là hằng số. Nếu tính cả chuỗi/số nhiều chữ số thì cộng chi phí xử lý/hiển thị giá trị.

`max_queue_len` đo số nút **đang chờ**, không phải số ô cấp phát. Cây dây chỉ chờ một nút nhưng mảng queue vẫn cấp phát n ô; bộ nhớ phụ và nhóm kết quả O(n). Khảo sát đếm thao tác ở n=3,7,31, so cây dây và cây đầy; không đo thời gian.

## 5. Giao diện mô phỏng

Mở `Giao_dien_truc_quan.html` bằng trình duyệt. Có cây mẫu, tự nhập cây, chạy từng bước/tự động/chạy hết. Đặt lại khởi động lại chính cây đang xem. Chỉ thêm vào vị trí con còn trống, tối đa 100 nút.

Input chấp nhận JSON hoặc bộ nút. Chuỗi có dấu phẩy/khoảng trắng cần dấu nháy kép:

```text
goc: 1
nut: (1, "Gốc cây", 2, 0), (2, 2.5, 0, 0)
```

Cây rỗng: `goc: 0; nut: []`. Input sai bị từ chối trước khi thay trạng thái. Số trong HTML dùng kiểu Number của JavaScript; cần giữ chính xác số nguyên lớn thì chạy Julia. Mô phỏng HTML không gọi Julia; ảnh chứng minh chạy Julia nên lấy từ demo/test/menu.

Kiểm tra logic HTML tùy chọn, chỉ cần Node, không cài gói:

```powershell
node test/gui_tests.cjs
```

## 6. Chốt mã và nộp bài

Repo GitHub thật: https://github.com/trucluong097-del/N24DCDT100_DT084_LuongMinhTruc

Bản này dùng Julia; README, mã, test và log được đóng gói cùng nhau. Chưa có 11 ảnh cá nhân và báo cáo trong repo này. SHA C lấy từ commit chứa mã/test/input, SHA S chốt sau khi bổ sung minh chứng. Sau khi tự chạy lại:

1. Đưa mã/test/input lên repo cá nhân, chốt **C**; ghi URL, SHA C và permalink thuật toán/test trong báo cáo.
2. Clone đúng C vào thư mục mới, kiểm HEAD và chạy lại để chụp A10. Tự chụp A01–A09 và A11 theo hướng dẫn lớp.
3. Thêm ảnh/báo cáo, chốt **S**. Clone S sang thư mục mới, chạy hai ví dụ/test. Nếu mã/test/input khác C, cập nhật minh chứng bị ảnh hưởng.
4. Ghi SHA S và kết quả chạy lại trong TXT nộp rời; không đưa SHA của chính S vào tệp thuộc S.
5. ZIP mã giữ code/test/README/log/ảnh gốc; bỏ .git, cache, tệp tạm. Bộ nộp còn cần Word, PDF và TXT.

Nhật ký chạy không thay 11 ảnh cá nhân. Ghi log mới bằng:

```powershell
.\Run_all.ps1 | Tee-Object -FilePath docs/logs/chay_lai.log
```


## 7. Clone repo này và chạy lại

```powershell
git -c core.autocrlf=false clone https://github.com/trucluong097-del/N24DCDT100_DT084_LuongMinhTruc.git
cd N24DCDT100_DT084_LuongMinhTruc
git rev-parse HEAD
.\Run_all.ps1
```
