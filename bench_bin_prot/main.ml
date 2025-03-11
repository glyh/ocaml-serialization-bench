open Core
open Bin_prot.Std

let rand_int64_of_range (lower : int64) (upper : int64) =
  let open Int64 in
  lower + Random.int64 (upper - lower)

module type Binprotable = sig
  type t

  val name : string
  val bin_size_t : t Bin_prot.Size.sizer
  val bin_read_t : t Bin_prot.Read.reader
  val bin_write_t : t Bin_prot.Write.writer
end

module BenchBinprot (B : Binprotable) = struct
  let time_it label f =
    let start_time = Time_ns.now () in
    let result = f () in
    let end_time = Time_ns.now () in
    let duration_ms = Time_ns.diff end_time start_time |> Time_ns.Span.to_ms in
    Printf.printf "%s took %f sec\n" label (duration_ms /. 1000.);
    result

  let bench_serialize (v : B.t) =
    let sz = B.bin_size_t v in
    let buf = Bin_prot.Common.create_buf sz in
    let label = Printf.sprintf "byte serializing %s" B.name in
    let _ = time_it label (fun _ -> B.bin_write_t buf ~pos:0 v) in
    buf

  let bench_deserialize (buf : Bin_prot.Common.buf) =
    let label = Printf.sprintf "byte deserializing %s" B.name in
    let result = time_it label (fun _ -> B.bin_read_t buf ~pos_ref:(ref 0)) in
    result

  let bench_round (v : B.t) =
    let serialized = bench_serialize v in
    bench_deserialize serialized |> ignore
end

module Int64List = struct
  type t = int64 list [@@deriving bin_io]

  let len = 50000000
  let min = -2147483648L
  let max = 2147483647L

  let name =
    Printf.sprintf
      "int64 list of len %d filled with element sampled from [%Ld, %Ld)" len min
      max

  let generate () : t = List.init len ~f:(fun _ -> rand_int64_of_range min max)
end

module Int64ListBench = BenchBinprot (Int64List)

let () =
  Random.init (Time_now.nanoseconds_since_unix_epoch () |> Int63.to_int_exn);
  Int64ListBench.bench_round (Int64List.generate ())
