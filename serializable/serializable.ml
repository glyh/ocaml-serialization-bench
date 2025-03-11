open Core

module type Serializable = sig
  type t

  val name : string
  val backend : string
  val serialize : t -> string
  val deserialize : string -> t
end

module Bench (S : Serializable) = struct
  let time_it label f =
    let start_time = Time_ns.now () in
    let result = f () in
    let end_time = Time_ns.now () in
    let duration_ms = Time_ns.diff end_time start_time |> Time_ns.Span.to_ms in
    Printf.printf "%s took %f sec\n" label (duration_ms /. 1000.);
    result

  let bench_serialize (v : S.t) =
    let label = Printf.sprintf "serializing %s" S.name in
    let result = time_it label (fun _ -> S.serialize v) in
    Printf.printf "Serialization result has length %d\n" (String.length result);
    result

  let bench_deserialize (buf : string) =
    let label = Printf.sprintf "deserializing %s" S.name in
    let result = time_it label (fun _ -> S.deserialize buf) in
    result

  let bench_round (v : S.t) =
    Printf.printf "==================\n";
    Printf.printf "Using backend %s\n" S.backend;
    let serialized = bench_serialize v in
    bench_deserialize serialized |> ignore
end
