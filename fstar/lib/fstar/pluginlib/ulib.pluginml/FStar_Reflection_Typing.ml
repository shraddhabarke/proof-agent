open Fstarcompiler
open Prims
let rec fold_left_dec : 'a 'b . 'a -> 'b Prims.list -> ('a -> 'b -> 'a) -> 'a
  =
  fun acc ->
    fun l ->
      fun f ->
        match l with | [] -> acc | x::xs -> fold_left_dec (f acc x) xs f
let rec map_dec : 'a 'b . 'a Prims.list -> ('a -> 'b) -> 'b Prims.list =
  fun l ->
    fun f -> match l with | [] -> [] | x::xs -> (f x) :: (map_dec xs f)
type ('a, 'b, 'f, 'xs, 'ys) zip2prop = Obj.t
let (lookup_bvar :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Prims.int ->
      Fstarcompiler.FStarC_Reflection_Types.term
        FStar_Pervasives_Native.option)
  = fun e -> fun x -> Prims.magic ()
let (lookup_fvar_uinst :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.fv ->
      Fstarcompiler.FStarC_Reflection_Types.universe Prims.list ->
        Fstarcompiler.FStarC_Reflection_Types.term
          FStar_Pervasives_Native.option)
  = fun e -> fun x -> fun us -> Prims.magic ()
let (lookup_fvar :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.fv ->
      Fstarcompiler.FStarC_Reflection_Types.term
        FStar_Pervasives_Native.option)
  = fun e -> fun x -> lookup_fvar_uinst e x []
type pp_name_t = (Prims.string, unit) FStar_Sealed_Inhabited.sealed
let (pp_name_default : pp_name_t) = FStar_Sealed_Inhabited.seal "x" "x"
let (seal_pp_name : Prims.string -> pp_name_t) =
  fun x -> FStar_Sealed_Inhabited.seal "x" x
let (tun : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown
type sort_t =
  (Fstarcompiler.FStarC_Reflection_Types.term, unit)
    FStar_Sealed_Inhabited.sealed
let (sort_default : sort_t) = FStar_Sealed_Inhabited.seal tun tun
let (seal_sort : Fstarcompiler.FStarC_Reflection_Types.term -> sort_t) =
  fun x -> FStar_Sealed_Inhabited.seal tun x
let (mk_binder :
  pp_name_t ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
        Fstarcompiler.FStarC_Reflection_Types.binder)
  =
  fun pp_name ->
    fun ty ->
      fun q ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_binder
          {
            Fstarcompiler.FStarC_Reflection_V2_Data.sort2 = ty;
            Fstarcompiler.FStarC_Reflection_V2_Data.qual = q;
            Fstarcompiler.FStarC_Reflection_V2_Data.attrs = [];
            Fstarcompiler.FStarC_Reflection_V2_Data.ppname2 = pp_name
          }
let (mk_simple_binder :
  pp_name_t ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_V2_Data.simple_binder)
  =
  fun pp_name ->
    fun ty ->
      Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_binder
        {
          Fstarcompiler.FStarC_Reflection_V2_Data.sort2 = ty;
          Fstarcompiler.FStarC_Reflection_V2_Data.qual =
            Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit;
          Fstarcompiler.FStarC_Reflection_V2_Data.attrs = [];
          Fstarcompiler.FStarC_Reflection_V2_Data.ppname2 = pp_name
        }
let (extend_env :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.env)
  =
  fun e ->
    fun x ->
      fun ty ->
        FStar_Reflection_V2_Derived.push_binding e
          {
            Fstarcompiler.FStarC_Reflection_V2_Data.uniq1 = x;
            Fstarcompiler.FStarC_Reflection_V2_Data.sort3 = ty;
            Fstarcompiler.FStarC_Reflection_V2_Data.ppname3 =
              (seal_pp_name "x")
          }
let (bv_index :
  Fstarcompiler.FStarC_Reflection_Types.bv ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var)
  =
  fun x ->
    (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_bv x).Fstarcompiler.FStarC_Reflection_V2_Data.index
let (namedv_uniq :
  Fstarcompiler.FStarC_Reflection_Types.namedv ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var)
  =
  fun x ->
    (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_namedv x).Fstarcompiler.FStarC_Reflection_V2_Data.uniq
let (binder_sort :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    Fstarcompiler.FStarC_Reflection_Types.typ)
  =
  fun b ->
    (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b).Fstarcompiler.FStarC_Reflection_V2_Data.sort2
let (binder_qual :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv)
  =
  fun b ->
    let uu___ = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b in
    match uu___ with
    | { Fstarcompiler.FStarC_Reflection_V2_Data.sort2 = uu___1;
        Fstarcompiler.FStarC_Reflection_V2_Data.qual = q;
        Fstarcompiler.FStarC_Reflection_V2_Data.attrs = uu___2;
        Fstarcompiler.FStarC_Reflection_V2_Data.ppname2 = uu___3;_} -> q
type subst_elt =
  | DT of Prims.nat * Fstarcompiler.FStarC_Reflection_Types.term 
  | NT of Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term 
  | ND of Fstarcompiler.FStarC_Reflection_V2_Data.var * Prims.nat 
let (uu___is_DT : subst_elt -> Prims.bool) =
  fun projectee ->
    match projectee with | DT (_0, _1) -> true | uu___ -> false
let (__proj__DT__item___0 : subst_elt -> Prims.nat) =
  fun projectee -> match projectee with | DT (_0, _1) -> _0
let (__proj__DT__item___1 :
  subst_elt -> Fstarcompiler.FStarC_Reflection_Types.term) =
  fun projectee -> match projectee with | DT (_0, _1) -> _1
let (uu___is_NT : subst_elt -> Prims.bool) =
  fun projectee ->
    match projectee with | NT (_0, _1) -> true | uu___ -> false
let (__proj__NT__item___0 :
  subst_elt -> Fstarcompiler.FStarC_Reflection_V2_Data.var) =
  fun projectee -> match projectee with | NT (_0, _1) -> _0
let (__proj__NT__item___1 :
  subst_elt -> Fstarcompiler.FStarC_Reflection_Types.term) =
  fun projectee -> match projectee with | NT (_0, _1) -> _1
let (uu___is_ND : subst_elt -> Prims.bool) =
  fun projectee ->
    match projectee with | ND (_0, _1) -> true | uu___ -> false
let (__proj__ND__item___0 :
  subst_elt -> Fstarcompiler.FStarC_Reflection_V2_Data.var) =
  fun projectee -> match projectee with | ND (_0, _1) -> _0
let (__proj__ND__item___1 : subst_elt -> Prims.nat) =
  fun projectee -> match projectee with | ND (_0, _1) -> _1
let (shift_subst_elt : Prims.nat -> subst_elt -> subst_elt) =
  fun n ->
    fun uu___ ->
      match uu___ with
      | DT (i, t) -> DT ((i + n), t)
      | NT (x, t) -> NT (x, t)
      | ND (x, i) -> ND (x, (i + n))
type subst = subst_elt Prims.list
let (shift_subst_n :
  Prims.nat -> subst_elt Prims.list -> subst_elt Prims.list) =
  fun n -> FStar_List_Tot_Base.map (shift_subst_elt n)
let (shift_subst : subst_elt Prims.list -> subst_elt Prims.list) =
  shift_subst_n Prims.int_one
let (maybe_uniq_of_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var
      FStar_Pervasives_Native.option)
  =
  fun x ->
    match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln x with
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var namedv ->
        FStar_Pervasives_Native.Some (namedv_uniq namedv)
    | uu___ -> FStar_Pervasives_Native.None
let rec (find_matching_subst_elt_bv :
  subst ->
    Fstarcompiler.FStarC_Reflection_Types.bv ->
      subst_elt FStar_Pervasives_Native.option)
  =
  fun s ->
    fun bv ->
      match s with
      | [] -> FStar_Pervasives_Native.None
      | (DT (j, t))::ss ->
          if j = (bv_index bv)
          then FStar_Pervasives_Native.Some (DT (j, t))
          else find_matching_subst_elt_bv ss bv
      | uu___::ss -> find_matching_subst_elt_bv ss bv
let (subst_db :
  Fstarcompiler.FStarC_Reflection_Types.bv ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun bv ->
    fun s ->
      match find_matching_subst_elt_bv s bv with
      | FStar_Pervasives_Native.Some (DT (uu___, t)) ->
          (match maybe_uniq_of_term t with
           | FStar_Pervasives_Native.None -> t
           | FStar_Pervasives_Native.Some k ->
               let v =
                 Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_namedv
                   {
                     Fstarcompiler.FStarC_Reflection_V2_Data.uniq = k;
                     Fstarcompiler.FStarC_Reflection_V2_Data.sort =
                       ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_bv
                           bv).Fstarcompiler.FStarC_Reflection_V2_Data.sort1);
                     Fstarcompiler.FStarC_Reflection_V2_Data.ppname =
                       ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_bv
                           bv).Fstarcompiler.FStarC_Reflection_V2_Data.ppname1)
                   } in
               Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                 (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var v))
      | uu___ ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar bv)
let rec (find_matching_subst_elt_var :
  subst ->
    Fstarcompiler.FStarC_Reflection_Types.namedv ->
      subst_elt FStar_Pervasives_Native.option)
  =
  fun s ->
    fun v ->
      match s with
      | [] -> FStar_Pervasives_Native.None
      | (NT (y, uu___))::rest ->
          if y = (namedv_uniq v)
          then FStar_Pervasives_Native.Some (FStar_List_Tot_Base.hd s)
          else find_matching_subst_elt_var rest v
      | (ND (y, uu___))::rest ->
          if y = (namedv_uniq v)
          then FStar_Pervasives_Native.Some (FStar_List_Tot_Base.hd s)
          else find_matching_subst_elt_var rest v
      | uu___::rest -> find_matching_subst_elt_var rest v
let (subst_var :
  Fstarcompiler.FStarC_Reflection_Types.namedv ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun v ->
    fun s ->
      match find_matching_subst_elt_var s v with
      | FStar_Pervasives_Native.Some (NT (uu___, t)) ->
          (match maybe_uniq_of_term t with
           | FStar_Pervasives_Native.None -> t
           | FStar_Pervasives_Native.Some k ->
               Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                 (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var
                    (Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_namedv
                       (let uu___1 =
                          Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_namedv
                            v in
                        {
                          Fstarcompiler.FStarC_Reflection_V2_Data.uniq = k;
                          Fstarcompiler.FStarC_Reflection_V2_Data.sort =
                            (uu___1.Fstarcompiler.FStarC_Reflection_V2_Data.sort);
                          Fstarcompiler.FStarC_Reflection_V2_Data.ppname =
                            (uu___1.Fstarcompiler.FStarC_Reflection_V2_Data.ppname)
                        }))))
      | FStar_Pervasives_Native.Some (ND (uu___, i)) ->
          let bv =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_bv
              {
                Fstarcompiler.FStarC_Reflection_V2_Data.index = i;
                Fstarcompiler.FStarC_Reflection_V2_Data.sort1 =
                  ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_namedv
                      v).Fstarcompiler.FStarC_Reflection_V2_Data.sort);
                Fstarcompiler.FStarC_Reflection_V2_Data.ppname1 =
                  ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_namedv
                      v).Fstarcompiler.FStarC_Reflection_V2_Data.ppname)
              } in
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar bv)
      | uu___ ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var v)
let (make_bv : Prims.nat -> Fstarcompiler.FStarC_Reflection_V2_Data.bv_view)
  =
  fun n ->
    {
      Fstarcompiler.FStarC_Reflection_V2_Data.index = n;
      Fstarcompiler.FStarC_Reflection_V2_Data.sort1 = sort_default;
      Fstarcompiler.FStarC_Reflection_V2_Data.ppname1 = pp_name_default
    }
let (make_bv_with_name :
  pp_name_t -> Prims.nat -> Fstarcompiler.FStarC_Reflection_V2_Data.bv_view)
  =
  fun s ->
    fun n ->
      {
        Fstarcompiler.FStarC_Reflection_V2_Data.index = n;
        Fstarcompiler.FStarC_Reflection_V2_Data.sort1 = sort_default;
        Fstarcompiler.FStarC_Reflection_V2_Data.ppname1 = s
      }
let (var_as_bv : Prims.nat -> Fstarcompiler.FStarC_Reflection_Types.bv) =
  fun v -> Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_bv (make_bv v)
let (make_namedv :
  Prims.nat -> Fstarcompiler.FStarC_Reflection_V2_Data.namedv_view) =
  fun n ->
    {
      Fstarcompiler.FStarC_Reflection_V2_Data.uniq = n;
      Fstarcompiler.FStarC_Reflection_V2_Data.sort = sort_default;
      Fstarcompiler.FStarC_Reflection_V2_Data.ppname = pp_name_default
    }
let (make_namedv_with_name :
  pp_name_t ->
    Prims.nat -> Fstarcompiler.FStarC_Reflection_V2_Data.namedv_view)
  =
  fun s ->
    fun n ->
      {
        Fstarcompiler.FStarC_Reflection_V2_Data.uniq = n;
        Fstarcompiler.FStarC_Reflection_V2_Data.sort = sort_default;
        Fstarcompiler.FStarC_Reflection_V2_Data.ppname = s
      }
let (var_as_namedv :
  Prims.nat -> Fstarcompiler.FStarC_Reflection_Types.namedv) =
  fun v ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_namedv
      {
        Fstarcompiler.FStarC_Reflection_V2_Data.uniq = v;
        Fstarcompiler.FStarC_Reflection_V2_Data.sort = sort_default;
        Fstarcompiler.FStarC_Reflection_V2_Data.ppname = pp_name_default
      }
let (var_as_term :
  Fstarcompiler.FStarC_Reflection_V2_Data.var ->
    Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun v ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
      (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var (var_as_namedv v))
let (binder_of_t_q :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
      Fstarcompiler.FStarC_Reflection_Types.binder)
  = fun t -> fun q -> mk_binder pp_name_default t q
let (mk_abs :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun ty ->
    fun qual ->
      fun t ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
          (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs
             ((binder_of_t_q ty qual), t))
let (mk_total :
  Fstarcompiler.FStarC_Reflection_Types.typ ->
    Fstarcompiler.FStarC_Reflection_Types.comp)
  =
  fun t ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
      (Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t)
let (mk_ghost :
  Fstarcompiler.FStarC_Reflection_Types.typ ->
    Fstarcompiler.FStarC_Reflection_Types.comp)
  =
  fun t ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
      (Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t)
let (mk_arrow :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
      Fstarcompiler.FStarC_Reflection_Types.typ ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun ty ->
    fun qual ->
      fun t ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
          (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
             ((binder_of_t_q ty qual), (mk_total t)))
let (mk_ghost_arrow :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
      Fstarcompiler.FStarC_Reflection_Types.typ ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun ty ->
    fun qual ->
      fun t ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
          (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
             ((binder_of_t_q ty qual), (mk_ghost t)))
let (bound_var : Prims.nat -> Fstarcompiler.FStarC_Reflection_Types.term) =
  fun i ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
      (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar
         (Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_bv (make_bv i)))
let (mk_let :
  pp_name_t ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term ->
          Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun ppname ->
    fun e1 ->
      fun t1 ->
        fun e2 ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
               (false, [], (mk_simple_binder ppname t1), e1, e2))
let (open_with_var_elt :
  Fstarcompiler.FStarC_Reflection_V2_Data.var -> Prims.nat -> subst_elt) =
  fun x ->
    fun i ->
      DT
        (i,
          (Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
             (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var
                (var_as_namedv x))))
let (open_with_var :
  Fstarcompiler.FStarC_Reflection_V2_Data.var -> Prims.nat -> subst) =
  fun x -> fun i -> [open_with_var_elt x i]
let (subst_ctx_uvar_and_subst :
  Fstarcompiler.FStarC_Reflection_Types.ctx_uvar_and_subst ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.ctx_uvar_and_subst)
  = fun uu___ -> fun uu___1 -> Prims.magic ()
let rec (binder_offset_patterns :
  (Fstarcompiler.FStarC_Reflection_V2_Data.pattern * Prims.bool) Prims.list
    -> Prims.nat)
  =
  fun ps ->
    match ps with
    | [] -> Prims.int_zero
    | (p, b)::ps1 ->
        let n = binder_offset_pattern p in
        let m = binder_offset_patterns ps1 in n + m
and (binder_offset_pattern :
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern -> Prims.nat) =
  fun p ->
    match p with
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant uu___ ->
        Prims.int_zero
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term uu___ ->
        Prims.int_zero
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (uu___, uu___1) ->
        Prims.int_one
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons (head, univs, subpats)
        -> binder_offset_patterns subpats
let rec (subst_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun t ->
    fun ss ->
      match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln t with
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (uu___, uu___1) -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar uu___ -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type uu___ -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const uu___ -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown -> t
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var x -> subst_var x ss
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar j -> subst_db j ss
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (hd, argv) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
               ((subst_term hd ss),
                 ((subst_term (FStar_Pervasives_Native.fst argv) ss),
                   (FStar_Pervasives_Native.snd argv))))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (b, body) ->
          let b' = subst_binder b ss in
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs
               (b', (subst_term body (shift_subst ss))))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (b, c) ->
          let b' = subst_binder b ss in
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
               (b', (subst_comp c (shift_subst ss))))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (b, f) ->
          let b1 = subst_binder b ss in
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine
               (b1, (subst_term f (shift_subst ss))))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (j, c) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar
               (j, (subst_ctx_uvar_and_subst c ss)))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
          (recf, attrs, b, def, body) ->
          let b1 = subst_binder b ss in
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
               (recf, (subst_terms attrs ss), b1,
                 (if recf
                  then subst_term def (shift_subst ss)
                  else subst_term def ss),
                 (subst_term body (shift_subst ss))))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match (scr, ret, brs) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
               ((subst_term scr ss),
                 (match ret with
                  | FStar_Pervasives_Native.None ->
                      FStar_Pervasives_Native.None
                  | FStar_Pervasives_Native.Some m ->
                      FStar_Pervasives_Native.Some (subst_match_returns m ss)),
                 (subst_branches brs ss)))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT (e, t1, tac, b)
          ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT
               ((subst_term e ss), (subst_term t1 ss),
                 (match tac with
                  | FStar_Pervasives_Native.None ->
                      FStar_Pervasives_Native.None
                  | FStar_Pervasives_Native.Some tac1 ->
                      FStar_Pervasives_Native.Some (subst_term tac1 ss)), b))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC (e, c, tac, b)
          ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC
               ((subst_term e ss), (subst_comp c ss),
                 (match tac with
                  | FStar_Pervasives_Native.None ->
                      FStar_Pervasives_Native.None
                  | FStar_Pervasives_Native.Some tac1 ->
                      FStar_Pervasives_Native.Some (subst_term tac1 ss)), b))
and (subst_binder :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.binder)
  =
  fun b ->
    fun ss ->
      let bndr = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b in
      Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_binder
        {
          Fstarcompiler.FStarC_Reflection_V2_Data.sort2 =
            (subst_term bndr.Fstarcompiler.FStarC_Reflection_V2_Data.sort2 ss);
          Fstarcompiler.FStarC_Reflection_V2_Data.qual =
            (bndr.Fstarcompiler.FStarC_Reflection_V2_Data.qual);
          Fstarcompiler.FStarC_Reflection_V2_Data.attrs =
            (subst_terms bndr.Fstarcompiler.FStarC_Reflection_V2_Data.attrs
               ss);
          Fstarcompiler.FStarC_Reflection_V2_Data.ppname2 =
            (bndr.Fstarcompiler.FStarC_Reflection_V2_Data.ppname2)
        }
and (subst_comp :
  Fstarcompiler.FStarC_Reflection_Types.comp ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.comp)
  =
  fun c ->
    fun ss ->
      match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_comp c with
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
            (Fstarcompiler.FStarC_Reflection_V2_Data.C_Total
               (subst_term t ss))
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
            (Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal
               (subst_term t ss))
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma (pre, post, pats) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
            (Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma
               ((subst_term pre ss), (subst_term post ss),
                 (subst_term pats ss)))
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
          (us, eff_name, res, args, decrs) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_comp
            (Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
               (us, eff_name, (subst_term res ss), (subst_args args ss),
                 (subst_terms decrs ss)))
and (subst_terms :
  Fstarcompiler.FStarC_Reflection_Types.term Prims.list ->
    subst -> Fstarcompiler.FStarC_Reflection_Types.term Prims.list)
  =
  fun ts ->
    fun ss ->
      match ts with
      | [] -> []
      | t::ts1 -> (subst_term t ss) :: (subst_terms ts1 ss)
and (subst_args :
  Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list ->
    subst -> Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list)
  =
  fun ts ->
    fun ss ->
      match ts with
      | [] -> []
      | (t, q)::ts1 -> ((subst_term t ss), q) :: (subst_args ts1 ss)
and (subst_patterns :
  (Fstarcompiler.FStarC_Reflection_V2_Data.pattern * Prims.bool) Prims.list
    ->
    subst ->
      (Fstarcompiler.FStarC_Reflection_V2_Data.pattern * Prims.bool)
        Prims.list)
  =
  fun ps ->
    fun ss ->
      match ps with
      | [] -> ps
      | (p, b)::ps1 ->
          let n = binder_offset_pattern p in
          let p1 = subst_pattern p ss in
          let ps2 = subst_patterns ps1 (shift_subst_n n ss) in (p1, b) :: ps2
and (subst_pattern :
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern ->
    subst -> Fstarcompiler.FStarC_Reflection_V2_Data.pattern)
  =
  fun p ->
    fun ss ->
      match p with
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant uu___ -> p
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons (fv, us, pats) ->
          let pats1 = subst_patterns pats ss in
          Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons (fv, us, pats1)
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (bv, s) ->
          Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (bv, s)
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term topt ->
          Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term
            ((match topt with
              | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
              | FStar_Pervasives_Native.Some t ->
                  FStar_Pervasives_Native.Some (subst_term t ss)))
and (subst_branch :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch ->
    subst -> Fstarcompiler.FStarC_Reflection_V2_Data.branch)
  =
  fun br ->
    fun ss ->
      let uu___ = br in
      match uu___ with
      | (p, t) ->
          let p1 = subst_pattern p ss in
          let j = binder_offset_pattern p1 in
          let t1 = subst_term t (shift_subst_n j ss) in (p1, t1)
and (subst_branches :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch Prims.list ->
    subst -> Fstarcompiler.FStarC_Reflection_V2_Data.branch Prims.list)
  =
  fun brs ->
    fun ss ->
      match brs with
      | [] -> []
      | br::brs1 -> (subst_branch br ss) :: (subst_branches brs1 ss)
and (subst_match_returns :
  Fstarcompiler.FStarC_Syntax_Syntax.match_returns_ascription ->
    subst -> Fstarcompiler.FStarC_Syntax_Syntax.match_returns_ascription)
  =
  fun m ->
    fun ss ->
      let uu___ = m in
      match uu___ with
      | (b, (ret, as_, eq)) ->
          let b1 = subst_binder b ss in
          let ret1 =
            match ret with
            | Fstarcompiler.FStar_Pervasives.Inl t ->
                Fstarcompiler.FStar_Pervasives.Inl
                  (subst_term t (shift_subst ss))
            | Fstarcompiler.FStar_Pervasives.Inr c ->
                Fstarcompiler.FStar_Pervasives.Inr
                  (subst_comp c (shift_subst ss)) in
          let as_1 =
            match as_ with
            | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
            | FStar_Pervasives_Native.Some t ->
                FStar_Pervasives_Native.Some (subst_term t (shift_subst ss)) in
          (b1, (ret1, as_1, eq))
let (open_with :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  = fun t -> fun v -> FStar_Reflection_Typing_Builtins.open_with t v
let (open_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  = fun t -> fun v -> FStar_Reflection_Typing_Builtins.open_term t v
let (close_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  = fun t -> fun v -> FStar_Reflection_Typing_Builtins.close_term t v
let (rename :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Fstarcompiler.FStarC_Reflection_V2_Data.var ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  = fun t -> fun x -> fun y -> FStar_Reflection_Typing_Builtins.rename t x y
let (constant_as_term :
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst ->
    Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun v ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
      (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const v)
let (unit_exp : Fstarcompiler.FStarC_Reflection_Types.term) =
  constant_as_term Fstarcompiler.FStarC_Reflection_V2_Data.C_Unit
let (unit_fv : Fstarcompiler.FStarC_Reflection_Types.fv) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
    FStar_Reflection_Const.unit_lid
let (unit_ty : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar unit_fv)
let (bool_fv : Fstarcompiler.FStarC_Reflection_Types.fv) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
    FStar_Reflection_Const.bool_lid
let (bool_ty : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar bool_fv)
let (u_zero : Fstarcompiler.FStarC_Reflection_Types.universe) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_universe
    Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Zero
let (u_max :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.universe ->
      Fstarcompiler.FStarC_Reflection_Types.universe)
  =
  fun u1 ->
    fun u2 ->
      Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_universe
        (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Max [u1; u2])
let (u_succ :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.universe)
  =
  fun u ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_universe
      (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Succ u)
let (tm_type :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun u ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
      (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type u)
let (tm_prop : Fstarcompiler.FStarC_Reflection_Types.term) =
  let prop_fv =
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
      FStar_Reflection_Const.prop_qn in
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar prop_fv)
let (eqtype_lid : Fstarcompiler.FStarC_Reflection_Types.name) =
  ["Prims"; "eqtype"]
let (true_bool : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const
       Fstarcompiler.FStarC_Reflection_V2_Data.C_True)
let (false_bool : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const
       Fstarcompiler.FStarC_Reflection_V2_Data.C_False)
let (eq2 :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term ->
          Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun u ->
    fun t ->
      fun v0 ->
        fun v1 ->
          let eq21 =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
              FStar_Reflection_Const.eq2_qn in
          let eq22 =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
              (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (eq21, [u])) in
          let h =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
              (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
                 (eq22,
                   (t, Fstarcompiler.FStarC_Reflection_V2_Data.Q_Implicit))) in
          let h1 =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
              (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
                 (h,
                   (v0, Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit))) in
          let h2 =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
              (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
                 (h1,
                   (v1, Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit))) in
          h2
let (b2t_lid : Fstarcompiler.FStarC_Reflection_Types.name) = ["Prims"; "b2t"]
let (b2t_fv : Fstarcompiler.FStarC_Reflection_Types.fv) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv b2t_lid
let (b2t_ty : Fstarcompiler.FStarC_Reflection_Types.term) =
  Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
    (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
       ((mk_binder (FStar_Sealed.seal "x") bool_ty
           Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit),
         (mk_total (tm_type u_zero))))
let rec (freevars :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun e ->
    match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln e with
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (uu___, uu___1) ->
        FStar_Set.complement (FStar_Set.empty ())
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (uu___, uu___1) ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar uu___ ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type uu___ ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const uu___ ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp -> FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar uu___ ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var x ->
        FStar_Set.singleton (namedv_uniq x)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (e1, (e2, uu___)) ->
        FStar_Set.union (freevars e1) (freevars e2)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (b, body) ->
        FStar_Set.union (freevars_binder b) (freevars body)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (b, c) ->
        FStar_Set.union (freevars_binder b) (freevars_comp c)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (b, f) ->
        FStar_Set.union (freevars (binder_sort b)) (freevars f)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
        (recf, attrs, b, def, body) ->
        FStar_Set.union
          (FStar_Set.union
             (FStar_Set.union (freevars_terms attrs)
                (freevars (binder_sort b))) (freevars def)) (freevars body)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match (scr, ret, brs) ->
        FStar_Set.union
          (FStar_Set.union (freevars scr)
             (freevars_opt ret freevars_match_returns))
          (freevars_branches brs)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT (e1, t, tac, b) ->
        FStar_Set.union (FStar_Set.union (freevars e1) (freevars t))
          (freevars_opt tac freevars)
    | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC (e1, c, tac, b) ->
        FStar_Set.union (FStar_Set.union (freevars e1) (freevars_comp c))
          (freevars_opt tac freevars)
and freevars_opt :
  'a .
    'a FStar_Pervasives_Native.option ->
      ('a -> Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set) ->
        Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set
  =
  fun o ->
    fun f ->
      match o with
      | FStar_Pervasives_Native.None -> FStar_Set.empty ()
      | FStar_Pervasives_Native.Some x -> f x
and (freevars_comp :
  Fstarcompiler.FStarC_Reflection_Types.comp ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun c ->
    match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_comp c with
    | Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t -> freevars t
    | Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t -> freevars t
    | Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma (pre, post, pats) ->
        FStar_Set.union (FStar_Set.union (freevars pre) (freevars post))
          (freevars pats)
    | Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
        (us, eff_name, res, args, decrs) ->
        FStar_Set.union (FStar_Set.union (freevars res) (freevars_args args))
          (freevars_terms decrs)
and (freevars_args :
  Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun ts ->
    match ts with
    | [] -> FStar_Set.empty ()
    | (t, q)::ts1 -> FStar_Set.union (freevars t) (freevars_args ts1)
and (freevars_terms :
  Fstarcompiler.FStarC_Reflection_Types.term Prims.list ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun ts ->
    match ts with
    | [] -> FStar_Set.empty ()
    | t::ts1 -> FStar_Set.union (freevars t) (freevars_terms ts1)
and (freevars_binder :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun b ->
    let bndr = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b in
    FStar_Set.union
      (freevars bndr.Fstarcompiler.FStarC_Reflection_V2_Data.sort2)
      (freevars_terms bndr.Fstarcompiler.FStarC_Reflection_V2_Data.attrs)
and (freevars_pattern :
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun p ->
    match p with
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant uu___ ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons (head, univs, subpats)
        -> freevars_patterns subpats
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (bv, s) ->
        FStar_Set.empty ()
    | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term topt ->
        freevars_opt topt freevars
and (freevars_patterns :
  (Fstarcompiler.FStarC_Reflection_V2_Data.pattern * Prims.bool) Prims.list
    -> Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun ps ->
    match ps with
    | [] -> FStar_Set.empty ()
    | (p, b)::ps1 ->
        FStar_Set.union (freevars_pattern p) (freevars_patterns ps1)
and (freevars_branch :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun br ->
    let uu___ = br in
    match uu___ with
    | (p, t) -> FStar_Set.union (freevars_pattern p) (freevars t)
and (freevars_branches :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch Prims.list ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun brs ->
    match brs with
    | [] -> FStar_Set.empty ()
    | hd::tl -> FStar_Set.union (freevars_branch hd) (freevars_branches tl)
and (freevars_match_returns :
  Fstarcompiler.FStarC_Syntax_Syntax.match_returns_ascription ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set)
  =
  fun m ->
    let uu___ = m in
    match uu___ with
    | (b, (ret, as_, eq)) ->
        let b1 = freevars_binder b in
        let ret1 =
          match ret with
          | Fstarcompiler.FStar_Pervasives.Inl t -> freevars t
          | Fstarcompiler.FStar_Pervasives.Inr c -> freevars_comp c in
        let as_1 = freevars_opt as_ freevars in
        FStar_Set.union (FStar_Set.union b1 ret1) as_1
let rec (ln' :
  Fstarcompiler.FStarC_Reflection_Types.term -> Prims.int -> Prims.bool) =
  fun e ->
    fun n ->
      match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln e with
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (uu___, uu___1) ->
          true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar uu___ -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type uu___ -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const uu___ -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var uu___ -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar m ->
          (bv_index m) <= n
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (e1, (e2, uu___)) ->
          (ln' e1 n) && (ln' e2 n)
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (b, body) ->
          (ln'_binder b n) && (ln' body (n + Prims.int_one))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (b, c) ->
          (ln'_binder b n) && (ln'_comp c (n + Prims.int_one))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (b, f) ->
          (ln'_binder b n) && (ln' f (n + Prims.int_one))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (uu___, uu___1) ->
          false
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
          (recf, attrs, b, def, body) ->
          (((ln'_terms attrs n) && (ln'_binder b n)) &&
             (if recf then ln' def (n + Prims.int_one) else ln' def n))
            && (ln' body (n + Prims.int_one))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match (scr, ret, brs) ->
          ((ln' scr n) &&
             (match ret with
              | FStar_Pervasives_Native.None -> true
              | FStar_Pervasives_Native.Some m -> ln'_match_returns m n))
            && (ln'_branches brs n)
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT (e1, t, tac, b)
          ->
          ((ln' e1 n) && (ln' t n)) &&
            ((match tac with
              | FStar_Pervasives_Native.None -> true
              | FStar_Pervasives_Native.Some tac1 -> ln' tac1 n))
      | Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC (e1, c, tac, b)
          ->
          ((ln' e1 n) && (ln'_comp c n)) &&
            ((match tac with
              | FStar_Pervasives_Native.None -> true
              | FStar_Pervasives_Native.Some tac1 -> ln' tac1 n))
and (ln'_comp :
  Fstarcompiler.FStarC_Reflection_Types.comp -> Prims.int -> Prims.bool) =
  fun c ->
    fun i ->
      match Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_comp c with
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t -> ln' t i
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t -> ln' t i
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma (pre, post, pats) ->
          ((ln' pre i) && (ln' post i)) && (ln' pats i)
      | Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
          (us, eff_name, res, args, decrs) ->
          ((ln' res i) && (ln'_args args i)) && (ln'_terms decrs i)
and (ln'_args :
  Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list ->
    Prims.int -> Prims.bool)
  =
  fun ts ->
    fun i ->
      match ts with
      | [] -> true
      | (t, q)::ts1 -> (ln' t i) && (ln'_args ts1 i)
and (ln'_binder :
  Fstarcompiler.FStarC_Reflection_Types.binder -> Prims.int -> Prims.bool) =
  fun b ->
    fun n ->
      let bndr = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b in
      (ln' bndr.Fstarcompiler.FStarC_Reflection_V2_Data.sort2 n) &&
        (ln'_terms bndr.Fstarcompiler.FStarC_Reflection_V2_Data.attrs n)
and (ln'_terms :
  Fstarcompiler.FStarC_Reflection_Types.term Prims.list ->
    Prims.int -> Prims.bool)
  =
  fun ts ->
    fun n ->
      match ts with | [] -> true | t::ts1 -> (ln' t n) && (ln'_terms ts1 n)
and (ln'_patterns :
  (Fstarcompiler.FStarC_Reflection_V2_Data.pattern * Prims.bool) Prims.list
    -> Prims.int -> Prims.bool)
  =
  fun ps ->
    fun i ->
      match ps with
      | [] -> true
      | (p, b)::ps1 ->
          let b0 = ln'_pattern p i in
          let n = binder_offset_pattern p in
          let b1 = ln'_patterns ps1 (i + n) in b0 && b1
and (ln'_pattern :
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern -> Prims.int -> Prims.bool)
  =
  fun p ->
    fun i ->
      match p with
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant uu___ -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons
          (head, univs, subpats) -> ln'_patterns subpats i
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (bv, s) -> true
      | Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term topt ->
          (match topt with
           | FStar_Pervasives_Native.None -> true
           | FStar_Pervasives_Native.Some t -> ln' t i)
and (ln'_branch :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch -> Prims.int -> Prims.bool)
  =
  fun br ->
    fun i ->
      let uu___ = br in
      match uu___ with
      | (p, t) ->
          let b = ln'_pattern p i in
          let j = binder_offset_pattern p in
          let b' = ln' t (i + j) in b && b'
and (ln'_branches :
  Fstarcompiler.FStarC_Reflection_V2_Data.branch Prims.list ->
    Prims.int -> Prims.bool)
  =
  fun brs ->
    fun i ->
      match brs with
      | [] -> true
      | br::brs1 -> (ln'_branch br i) && (ln'_branches brs1 i)
and (ln'_match_returns :
  Fstarcompiler.FStarC_Syntax_Syntax.match_returns_ascription ->
    Prims.int -> Prims.bool)
  =
  fun m ->
    fun i ->
      let uu___ = m in
      match uu___ with
      | (b, (ret, as_, eq)) ->
          let b1 = ln'_binder b i in
          let ret1 =
            match ret with
            | Fstarcompiler.FStar_Pervasives.Inl t ->
                ln' t (i + Prims.int_one)
            | Fstarcompiler.FStar_Pervasives.Inr c ->
                ln'_comp c (i + Prims.int_one) in
          let as_1 =
            match as_ with
            | FStar_Pervasives_Native.None -> true
            | FStar_Pervasives_Native.Some t -> ln' t (i + Prims.int_one) in
          (b1 && ret1) && as_1
let (ln : Fstarcompiler.FStarC_Reflection_Types.term -> Prims.bool) =
  fun t -> ln' t (Prims.of_int (-1))
let (ln_comp : Fstarcompiler.FStarC_Reflection_Types.comp -> Prims.bool) =
  fun c -> ln'_comp c (Prims.of_int (-1))
type term_ctxt =
  | Ctxt_hole 
  | Ctxt_app_head of term_ctxt * Fstarcompiler.FStarC_Reflection_V2_Data.argv
  
  | Ctxt_app_arg of Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv * term_ctxt 
let uu___is_Ctxt_hole uu___ =
  match uu___ with | Ctxt_hole _ -> true | _ -> false
let uu___is_Ctxt_app_head uu___ =
  match uu___ with | Ctxt_app_head _ -> true | _ -> false
let uu___is_Ctxt_app_arg uu___ =
  match uu___ with | Ctxt_app_arg _ -> true | _ -> false
let rec (apply_term_ctxt :
  term_ctxt ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun e ->
    fun t ->
      match e with
      | Ctxt_hole -> t
      | Ctxt_app_head (e1, arg) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
               ((apply_term_ctxt e1 t), arg))
      | Ctxt_app_arg (hd, q, e1) ->
          Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
            (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
               (hd, ((apply_term_ctxt e1 t), q)))
type ('dummyV0, 'dummyV1) constant_typing =
  | CT_Unit 
  | CT_True 
  | CT_False 
let (uu___is_CT_Unit :
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      (unit, unit) constant_typing -> Prims.bool)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | CT_Unit -> true | uu___2 -> false
let (uu___is_CT_True :
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      (unit, unit) constant_typing -> Prims.bool)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | CT_True -> true | uu___2 -> false
let (uu___is_CT_False :
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      (unit, unit) constant_typing -> Prims.bool)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | CT_False -> true | uu___2 -> false
type ('dummyV0, 'dummyV1) univ_eq =
  | UN_Refl of Fstarcompiler.FStarC_Reflection_Types.universe 
  | UN_MaxCongL of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * (unit, unit) univ_eq 
  | UN_MaxCongR of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * (unit, unit) univ_eq 
  | UN_MaxComm of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe 
  | UN_MaxLeq of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * (unit, unit) univ_leq 
and ('dummyV0, 'dummyV1) univ_leq =
  | UNLEQ_Refl of Fstarcompiler.FStarC_Reflection_Types.universe 
  | UNLEQ_Succ of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * (unit, unit) univ_leq 
  | UNLEQ_Max of Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe 
let uu___is_UN_Refl uu___1 uu___ uu___2 =
  match uu___2 with | UN_Refl _ -> true | _ -> false
let uu___is_UN_MaxCongL uu___1 uu___ uu___2 =
  match uu___2 with | UN_MaxCongL _ -> true | _ -> false
let uu___is_UN_MaxCongR uu___1 uu___ uu___2 =
  match uu___2 with | UN_MaxCongR _ -> true | _ -> false
let uu___is_UN_MaxComm uu___1 uu___ uu___2 =
  match uu___2 with | UN_MaxComm _ -> true | _ -> false
let uu___is_UN_MaxLeq uu___1 uu___ uu___2 =
  match uu___2 with | UN_MaxLeq _ -> true | _ -> false
let uu___is_UNLEQ_Refl uu___1 uu___ uu___2 =
  match uu___2 with | UNLEQ_Refl _ -> true | _ -> false
let uu___is_UNLEQ_Succ uu___1 uu___ uu___2 =
  match uu___2 with | UNLEQ_Succ _ -> true | _ -> false
let uu___is_UNLEQ_Max uu___1 uu___ uu___2 =
  match uu___2 with | UNLEQ_Max _ -> true | _ -> false
let (mk_if :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun scrutinee ->
    fun then_ ->
      fun else_ ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
          (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
             (scrutinee, FStar_Pervasives_Native.None,
               [((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                    Fstarcompiler.FStarC_Reflection_V2_Data.C_True), then_);
               ((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                   Fstarcompiler.FStarC_Reflection_V2_Data.C_False), else_)]))
type comp_typ =
  (Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
    Fstarcompiler.FStarC_Reflection_Types.typ)
let (close_comp_typ' :
  comp_typ ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Prims.nat ->
        (Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
          Fstarcompiler.FStarC_Reflection_Types.term))
  =
  fun c ->
    fun x ->
      fun i ->
        ((FStar_Pervasives_Native.fst c),
          (subst_term (FStar_Pervasives_Native.snd c) [ND (x, i)]))
let (close_comp_typ :
  comp_typ ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      (Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
        Fstarcompiler.FStarC_Reflection_Types.term))
  = fun c -> fun x -> close_comp_typ' c x Prims.int_zero
let (open_comp_typ' :
  comp_typ ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      Prims.nat ->
        (Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
          Fstarcompiler.FStarC_Reflection_Types.term))
  =
  fun c ->
    fun x ->
      fun i ->
        ((FStar_Pervasives_Native.fst c),
          (subst_term (FStar_Pervasives_Native.snd c) (open_with_var x i)))
let (open_comp_typ :
  comp_typ ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var ->
      (Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
        Fstarcompiler.FStarC_Reflection_Types.term))
  = fun c -> fun x -> open_comp_typ' c x Prims.int_zero
let (freevars_comp_typ :
  comp_typ -> Fstarcompiler.FStarC_Reflection_V2_Data.var FStar_Set.set) =
  fun c -> freevars (FStar_Pervasives_Native.snd c)
let (mk_comp : comp_typ -> Fstarcompiler.FStarC_Reflection_Types.comp) =
  fun c ->
    match FStar_Pervasives_Native.fst c with
    | Fstarcompiler.FStarC_TypeChecker_Core.E_Total ->
        mk_total (FStar_Pervasives_Native.snd c)
    | Fstarcompiler.FStarC_TypeChecker_Core.E_Ghost ->
        mk_ghost (FStar_Pervasives_Native.snd c)
let (mk_arrow_ct :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
      comp_typ -> Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun ty ->
    fun qual ->
      fun c ->
        Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
          (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
             ((binder_of_t_q ty qual), (mk_comp c)))
type relation =
  | R_Eq 
  | R_Sub 
let (uu___is_R_Eq : relation -> Prims.bool) =
  fun projectee -> match projectee with | R_Eq -> true | uu___ -> false
let (uu___is_R_Sub : relation -> Prims.bool) =
  fun projectee -> match projectee with | R_Sub -> true | uu___ -> false
type binding =
  (Fstarcompiler.FStarC_Reflection_V2_Data.var *
    Fstarcompiler.FStarC_Reflection_Types.term)
type bindings = binding Prims.list
let rename_bindings :
  'uuuuu .
    ('uuuuu * Fstarcompiler.FStarC_Reflection_Types.term) Prims.list ->
      Fstarcompiler.FStarC_Reflection_V2_Data.var ->
        Fstarcompiler.FStarC_Reflection_V2_Data.var ->
          ('uuuuu * Fstarcompiler.FStarC_Reflection_Types.term) Prims.list
  =
  fun bs ->
    fun x ->
      fun y ->
        FStar_List_Tot_Base.map
          (fun uu___ -> match uu___ with | (v, t) -> (v, (rename t x y))) bs
let rec (extend_env_l :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    bindings -> Fstarcompiler.FStarC_Reflection_Types.env)
  =
  fun g ->
    fun bs ->
      match bs with
      | [] -> g
      | (x, t)::bs1 -> extend_env (extend_env_l g bs1) x t
let (is_non_informative_name :
  Fstarcompiler.FStarC_Reflection_Types.name -> Prims.bool) =
  fun l ->
    ((l = FStar_Reflection_Const.unit_lid) ||
       (l = FStar_Reflection_Const.squash_qn))
      || (l = ["FStar"; "Ghost"; "erased"])
let (is_non_informative_fv :
  Fstarcompiler.FStarC_Reflection_Types.fv -> Prims.bool) =
  fun f ->
    is_non_informative_name
      (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_fv f)
let rec (__close_term_vs :
  Prims.nat ->
    Fstarcompiler.FStarC_Reflection_V2_Data.var Prims.list ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun i ->
    fun vs ->
      fun t ->
        match vs with
        | [] -> t
        | v::vs1 ->
            subst_term (__close_term_vs (i + Prims.int_one) vs1 t)
              [ND (v, i)]
let (close_term_vs :
  Fstarcompiler.FStarC_Reflection_V2_Data.var Prims.list ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  = fun vs -> fun t -> __close_term_vs Prims.int_zero vs t
let (close_term_bs :
  binding Prims.list ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun bs ->
    fun t ->
      close_term_vs (FStar_List_Tot_Base.map FStar_Pervasives_Native.fst bs)
        t
let (bindings_to_refl_bindings :
  binding Prims.list ->
    Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list)
  =
  fun bs ->
    FStar_List_Tot_Base.map
      (fun uu___ ->
         match uu___ with
         | (v, ty) ->
             {
               Fstarcompiler.FStarC_Reflection_V2_Data.uniq1 = v;
               Fstarcompiler.FStarC_Reflection_V2_Data.sort3 = ty;
               Fstarcompiler.FStarC_Reflection_V2_Data.ppname3 =
                 pp_name_default
             }) bs
let (refl_bindings_to_bindings :
  Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list ->
    binding Prims.list)
  =
  fun bs ->
    FStar_List_Tot_Base.map
      (fun b ->
         ((b.Fstarcompiler.FStarC_Reflection_V2_Data.uniq1),
           (b.Fstarcompiler.FStarC_Reflection_V2_Data.sort3))) bs
type ('dummyV0, 'dummyV1) non_informative =
  | Non_informative_type of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.universe 
  | Non_informative_fv of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv 
  | Non_informative_uinst of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv *
  Fstarcompiler.FStarC_Reflection_Types.universe Prims.list 
  | Non_informative_app of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.argv * (unit, unit) non_informative
  
  | Non_informative_total_arrow of Fstarcompiler.FStarC_Reflection_Types.env
  * Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_Reflection_Types.term * (unit, unit) non_informative 
  | Non_informative_ghost_arrow of Fstarcompiler.FStarC_Reflection_Types.env
  * Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_Reflection_Types.term 
  | Non_informative_token of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.typ * unit 
let uu___is_Non_informative_type uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_type _ -> true | _ -> false
let uu___is_Non_informative_fv uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_fv _ -> true | _ -> false
let uu___is_Non_informative_uinst uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_uinst _ -> true | _ -> false
let uu___is_Non_informative_app uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_app _ -> true | _ -> false
let uu___is_Non_informative_total_arrow uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_total_arrow _ -> true | _ -> false
let uu___is_Non_informative_ghost_arrow uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_ghost_arrow _ -> true | _ -> false
let uu___is_Non_informative_token uu___1 uu___ uu___2 =
  match uu___2 with | Non_informative_token _ -> true | _ -> false
type ('bnds, 'pat, 'uuuuu) bindings_ok_for_pat = Obj.t
type ('g, 'bs, 'br) bindings_ok_for_branch = Obj.t
type ('g, 'bss, 'brs) bindings_ok_for_branch_N = Obj.t
let (binding_to_namedv :
  Fstarcompiler.FStarC_Reflection_V2_Data.binding ->
    Fstarcompiler.FStarC_Reflection_Types.namedv)
  =
  fun b ->
    Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_namedv
      {
        Fstarcompiler.FStarC_Reflection_V2_Data.uniq =
          (b.Fstarcompiler.FStarC_Reflection_V2_Data.uniq1);
        Fstarcompiler.FStarC_Reflection_V2_Data.sort =
          (FStar_Sealed.seal b.Fstarcompiler.FStarC_Reflection_V2_Data.sort3);
        Fstarcompiler.FStarC_Reflection_V2_Data.ppname =
          (b.Fstarcompiler.FStarC_Reflection_V2_Data.ppname3)
      }
let rec (elaborate_pat :
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern ->
    Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list ->
      (Fstarcompiler.FStarC_Reflection_Types.term *
        Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list)
        FStar_Pervasives_Native.option)
  =
  fun p ->
    fun bs ->
      match (p, bs) with
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant c, uu___) ->
          FStar_Pervasives_Native.Some
            ((Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const c)), bs)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Cons
         (fv, univs, subpats), bs1) ->
          let head =
            match univs with
            | FStar_Pervasives_Native.Some univs1 ->
                Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                  (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst
                     (fv, univs1))
            | FStar_Pervasives_Native.None ->
                Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                  (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar fv) in
          fold_left_dec (FStar_Pervasives_Native.Some (head, bs1)) subpats
            (fun st ->
               fun pi ->
                 let uu___ = pi in
                 match uu___ with
                 | (p1, i) ->
                     (match st with
                      | FStar_Pervasives_Native.None ->
                          FStar_Pervasives_Native.None
                      | FStar_Pervasives_Native.Some (head1, bs2) ->
                          (match elaborate_pat p1 bs2 with
                           | FStar_Pervasives_Native.None ->
                               FStar_Pervasives_Native.None
                           | FStar_Pervasives_Native.Some (t, bs') ->
                               FStar_Pervasives_Native.Some
                                 ((Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                                     (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
                                        (head1,
                                          (t,
                                            (if i
                                             then
                                               Fstarcompiler.FStarC_Reflection_V2_Data.Q_Implicit
                                             else
                                               Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit))))),
                                   bs'))))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Var (uu___, uu___1),
         b::bs1) ->
          FStar_Pervasives_Native.Some
            ((Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_ln
                (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var
                   (binding_to_namedv b))), bs1)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term
         (FStar_Pervasives_Native.Some t), uu___) ->
          FStar_Pervasives_Native.Some (t, bs)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Dot_Term
         (FStar_Pervasives_Native.None), uu___) ->
          FStar_Pervasives_Native.None
      | uu___ -> FStar_Pervasives_Native.None
type ('dummyV0, 'dummyV1, 'dummyV2) typing =
  | T_Token of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term * comp_typ * unit 
  | T_Var of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.namedv 
  | T_FVar of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv 
  | T_UInst of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv *
  Fstarcompiler.FStarC_Reflection_Types.universe Prims.list 
  | T_Const of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst *
  Fstarcompiler.FStarC_Reflection_Types.term * (unit, unit) constant_typing 
  | T_Abs of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * comp_typ *
  Fstarcompiler.FStarC_Reflection_Types.universe * pp_name_t *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing 
  | T_App of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.binder *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing 
  | T_Let of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * pp_name_t * (unit,
  unit, unit) typing * (unit, unit, unit) typing 
  | T_Arrow of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * pp_name_t *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing 
  | T_Refine of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing 
  | T_PropIrrelevance of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing 
  | T_Sub of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term * comp_typ * comp_typ * (
  unit, unit, unit) typing * (unit, unit, unit, unit) related_comp 
  | T_If of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * (unit, unit, unit) typing * (unit, unit, unit) typing * (unit,
  unit, unit) typing 
  | T_Match of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, unit, unit)
  typing * Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * (unit, 
  unit, unit) typing * Fstarcompiler.FStarC_Reflection_V2_Data.branch
  Prims.list * comp_typ * Fstarcompiler.FStarC_Reflection_V2_Data.binding
  Prims.list Prims.list * (unit, unit, unit, unit, unit) match_is_complete *
  (unit, unit, unit, unit, unit, unit, unit) branches_typing 
and ('dummyV0, 'dummyV1, 'dummyV2, 'dummyV3) related =
  | Rel_refl of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term * relation 
  | Rel_sym of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * (unit, unit, unit, unit)
  related 
  | Rel_trans of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * relation * (unit, unit, 
  unit, unit) related * (unit, unit, unit, unit) related 
  | Rel_univ of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.universe *
  Fstarcompiler.FStarC_Reflection_Types.universe * (unit, unit) univ_eq 
  | Rel_beta of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term 
  | Rel_eq_token of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * unit 
  | Rel_subtyping_token of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * unit 
  | Rel_equiv of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * relation * (unit, unit, 
  unit, unit) related 
  | Rel_arrow of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv * comp_typ * comp_typ *
  relation * Fstarcompiler.FStarC_Reflection_V2_Data.var * (unit, unit, 
  unit, unit) related * (unit, unit, unit, unit) related_comp 
  | Rel_abs of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.aqualv *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_V2_Data.var * (unit, unit, unit, unit)
  related * (unit, unit, unit, unit) related 
  | Rel_ctxt of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term * term_ctxt * (unit, unit, 
  unit, unit) related 
and ('dummyV0, 'dummyV1, 'dummyV2, 'dummyV3) related_comp =
  | Relc_typ of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost * relation * (unit,
  unit, unit, unit) related 
  | Relc_total_ghost of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term 
  | Relc_ghost_total of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term * (unit, unit) non_informative 
and ('g, 'scuu, 'scuty, 'sc, 'rty, 'dummyV0, 'dummyV1) branches_typing =
  | BT_Nil 
  | BT_S of Fstarcompiler.FStarC_Reflection_V2_Data.branch *
  Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list * (unit, 
  unit, unit, unit, unit, unit, unit) branch_typing *
  Fstarcompiler.FStarC_Reflection_V2_Data.branch Prims.list *
  Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list Prims.list *
  (unit, unit, unit, unit, unit, unit, unit) branches_typing 
and ('g, 'scuu, 'scuty, 'sc, 'rty, 'dummyV0, 'dummyV1) branch_typing =
  | BO of Fstarcompiler.FStarC_Reflection_V2_Data.pattern *
  Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list *
  Fstarcompiler.FStarC_Reflection_V2_Data.var *
  Fstarcompiler.FStarC_Reflection_Types.term * unit * (unit, unit, unit)
  typing 
and ('dummyV0, 'dummyV1, 'dummyV2, 'dummyV3, 'dummyV4) match_is_complete =
  | MC_Tok of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.term *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_Reflection_V2_Data.pattern Prims.list *
  Fstarcompiler.FStarC_Reflection_V2_Data.binding Prims.list Prims.list *
  unit 
let uu___is_T_Token uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Token _ -> true | _ -> false
let uu___is_T_Var uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Var _ -> true | _ -> false
let uu___is_T_FVar uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_FVar _ -> true | _ -> false
let uu___is_T_UInst uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_UInst _ -> true | _ -> false
let uu___is_T_Const uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Const _ -> true | _ -> false
let uu___is_T_Abs uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Abs _ -> true | _ -> false
let uu___is_T_App uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_App _ -> true | _ -> false
let uu___is_T_Let uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Let _ -> true | _ -> false
let uu___is_T_Arrow uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Arrow _ -> true | _ -> false
let uu___is_T_Refine uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Refine _ -> true | _ -> false
let uu___is_T_PropIrrelevance uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_PropIrrelevance _ -> true | _ -> false
let uu___is_T_Sub uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Sub _ -> true | _ -> false
let uu___is_T_If uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_If _ -> true | _ -> false
let uu___is_T_Match uu___2 uu___1 uu___ uu___3 =
  match uu___3 with | T_Match _ -> true | _ -> false
let uu___is_Rel_refl uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_refl _ -> true | _ -> false
let uu___is_Rel_sym uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_sym _ -> true | _ -> false
let uu___is_Rel_trans uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_trans _ -> true | _ -> false
let uu___is_Rel_univ uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_univ _ -> true | _ -> false
let uu___is_Rel_beta uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_beta _ -> true | _ -> false
let uu___is_Rel_eq_token uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_eq_token _ -> true | _ -> false
let uu___is_Rel_subtyping_token uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_subtyping_token _ -> true | _ -> false
let uu___is_Rel_equiv uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_equiv _ -> true | _ -> false
let uu___is_Rel_arrow uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_arrow _ -> true | _ -> false
let uu___is_Rel_abs uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_abs _ -> true | _ -> false
let uu___is_Rel_ctxt uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Rel_ctxt _ -> true | _ -> false
let uu___is_Relc_typ uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Relc_typ _ -> true | _ -> false
let uu___is_Relc_total_ghost uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Relc_total_ghost _ -> true | _ -> false
let uu___is_Relc_ghost_total uu___3 uu___2 uu___1 uu___ uu___4 =
  match uu___4 with | Relc_ghost_total _ -> true | _ -> false
let uu___is_BT_Nil uu___6 uu___5 uu___4 uu___3 uu___2 uu___1 uu___ uu___7 =
  match uu___7 with | BT_Nil _ -> true | _ -> false
let uu___is_BT_S uu___6 uu___5 uu___4 uu___3 uu___2 uu___1 uu___ uu___7 =
  match uu___7 with | BT_S _ -> true | _ -> false
let uu___is_BO uu___6 uu___5 uu___4 uu___3 uu___2 uu___1 uu___ uu___7 =
  match uu___7 with | BO _ -> true | _ -> false
let uu___is_MC_Tok uu___4 uu___3 uu___2 uu___1 uu___ uu___5 =
  match uu___5 with | MC_Tok _ -> true | _ -> false
type ('g, 't1, 't2) sub_typing = (unit, unit, unit, unit) related
type ('g, 'c1, 'c2) sub_comp = (unit, unit, unit, unit) related_comp
type ('g, 't1, 't2) equiv = (unit, unit, unit, unit) related
type ('g, 'e, 't) tot_typing = (unit, unit, unit) typing
type ('g, 'e, 't) ghost_typing = (unit, unit, unit) typing
let (subtyping_token_renaming :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    bindings ->
      bindings ->
        Fstarcompiler.FStarC_Reflection_V2_Data.var ->
          Fstarcompiler.FStarC_Reflection_V2_Data.var ->
            Fstarcompiler.FStarC_Reflection_Types.term ->
              Fstarcompiler.FStarC_Reflection_Types.term ->
                Fstarcompiler.FStarC_Reflection_Types.term ->
                  (unit, unit, unit)
                    Fstarcompiler.FStarC_Tactics_Types_Reflection.subtyping_token
                    ->
                    (unit, unit, unit)
                      Fstarcompiler.FStarC_Tactics_Types_Reflection.subtyping_token)
  =
  fun g ->
    fun bs0 ->
      fun bs1 ->
        fun x ->
          fun y -> fun t -> fun t0 -> fun t1 -> fun d -> Prims.magic ()
let (subtyping_token_weakening :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    bindings ->
      bindings ->
        Fstarcompiler.FStarC_Reflection_V2_Data.var ->
          Fstarcompiler.FStarC_Reflection_Types.term ->
            Fstarcompiler.FStarC_Reflection_Types.term ->
              Fstarcompiler.FStarC_Reflection_Types.term ->
                (unit, unit, unit)
                  Fstarcompiler.FStarC_Tactics_Types_Reflection.subtyping_token
                  ->
                  (unit, unit, unit)
                    Fstarcompiler.FStarC_Tactics_Types_Reflection.subtyping_token)
  =
  fun g ->
    fun bs0 ->
      fun bs1 ->
        fun x -> fun t -> fun t0 -> fun t1 -> fun d -> Prims.magic ()
let (simplify_umax :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.universe ->
        (unit, unit, unit) typing -> (unit, unit, unit) typing)
  =
  fun g ->
    fun t ->
      fun u ->
        fun d ->
          let ue = UN_MaxLeq (u, u, (UNLEQ_Refl u)) in
          let du = Rel_univ (g, (u_max u u), u, ue) in
          let du1 =
            Rel_equiv (g, (tm_type (u_max u u)), (tm_type u), R_Sub, du) in
          T_Sub
            (g, t,
              (Fstarcompiler.FStarC_TypeChecker_Core.E_Total,
                (tm_type (u_max u u))),
              (Fstarcompiler.FStarC_TypeChecker_Core.E_Total, (tm_type u)),
              d,
              (Relc_typ
                 (g, (tm_type (u_max u u)), (tm_type u),
                   Fstarcompiler.FStarC_TypeChecker_Core.E_Total, R_Sub, du1)))
let (equiv_arrow :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.typ ->
          Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
            Fstarcompiler.FStarC_Reflection_V2_Data.var ->
              (unit, unit, unit) equiv -> (unit, unit, unit) equiv)
  =
  fun g ->
    fun e1 ->
      fun e2 ->
        fun ty ->
          fun q ->
            fun x ->
              fun eq ->
                let c1 = (Fstarcompiler.FStarC_TypeChecker_Core.E_Total, e1) in
                let c2 = (Fstarcompiler.FStarC_TypeChecker_Core.E_Total, e2) in
                Rel_arrow
                  (g, ty, ty, q, c1, c2, R_Eq, x, (Rel_refl (g, ty, R_Eq)),
                    (Relc_typ
                       ((extend_env g x ty),
                         (subst_term e1 (open_with_var x Prims.int_zero)),
                         (subst_term e2 (open_with_var x Prims.int_zero)),
                         (FStar_Pervasives_Native.fst c1), R_Eq, eq)))
let (equiv_abs_close :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.typ ->
          Fstarcompiler.FStarC_Reflection_V2_Data.aqualv ->
            Fstarcompiler.FStarC_Reflection_V2_Data.var ->
              (unit, unit, unit) equiv -> (unit, unit, unit) equiv)
  =
  fun g ->
    fun e1 ->
      fun e2 ->
        fun ty ->
          fun q ->
            fun x ->
              fun eq ->
                let eq1 = eq in
                Rel_abs
                  (g, ty, ty, q, (subst_term e1 [ND (x, Prims.int_zero)]),
                    (subst_term e2 [ND (x, Prims.int_zero)]), x,
                    (Rel_refl (g, ty, R_Eq)), eq1)
type 'g fstar_env_fvs = unit
type fstar_env = Fstarcompiler.FStarC_Reflection_Types.env
type fstar_top_env = fstar_env
type ('dummyV0, 'dummyV1) sigelt_typing =
  | ST_Let of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv *
  Fstarcompiler.FStarC_Reflection_Types.typ *
  Fstarcompiler.FStarC_Reflection_Types.term * unit 
  | ST_Let_Opaque of Fstarcompiler.FStarC_Reflection_Types.env *
  Fstarcompiler.FStarC_Reflection_Types.fv *
  Fstarcompiler.FStarC_Reflection_Types.typ * unit 
let (uu___is_ST_Let :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Prims.bool)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with
        | ST_Let (g, fv, ty, tm, _4) -> true
        | uu___2 -> false
let (__proj__ST_Let__item__g :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.env)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee -> match projectee with | ST_Let (g, fv, ty, tm, _4) -> g
let (__proj__ST_Let__item__fv :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.fv)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let (g, fv, ty, tm, _4) -> fv
let (__proj__ST_Let__item__ty :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.typ)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let (g, fv, ty, tm, _4) -> ty
let (__proj__ST_Let__item__tm :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing ->
        Fstarcompiler.FStarC_Reflection_Types.term)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let (g, fv, ty, tm, _4) -> tm
let (uu___is_ST_Let_Opaque :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Prims.bool)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with
        | ST_Let_Opaque (g, fv, ty, _3) -> true
        | uu___2 -> false
let (__proj__ST_Let_Opaque__item__g :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.env)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let_Opaque (g, fv, ty, _3) -> g
let (__proj__ST_Let_Opaque__item__fv :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.fv)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let_Opaque (g, fv, ty, _3) -> fv
let (__proj__ST_Let_Opaque__item__ty :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.sigelt ->
      (unit, unit) sigelt_typing -> Fstarcompiler.FStarC_Reflection_Types.typ)
  =
  fun uu___ ->
    fun uu___1 ->
      fun projectee ->
        match projectee with | ST_Let_Opaque (g, fv, ty, _3) -> ty
type blob = (Prims.string * Fstarcompiler.FStarC_Reflection_Types.term)
type ('s, 't) sigelt_has_type = Obj.t
type ('g, 't) sigelt_for =
  (Prims.bool * Fstarcompiler.FStarC_Reflection_Types.sigelt * blob
    FStar_Pervasives_Native.option)
type ('g, 't) dsl_tac_result_t =
  ((unit, unit) sigelt_for Prims.list * (unit, unit) sigelt_for * (unit,
    unit) sigelt_for Prims.list)
type dsl_tac_t =
  (fstar_top_env * Fstarcompiler.FStarC_Reflection_Types.typ
    FStar_Pervasives_Native.option) ->
    ((unit, unit) dsl_tac_result_t, unit) FStar_Tactics_Effect.tac_repr
let (if_complete_match :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      (unit, unit, unit, unit, unit)
        FStarC_Tactics_V2_Builtins.match_complete_token)
  = fun g -> fun t -> Prims.magic ()
let (mkif :
  fstar_env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      Fstarcompiler.FStarC_Reflection_Types.term ->
        Fstarcompiler.FStarC_Reflection_Types.term ->
          Fstarcompiler.FStarC_Reflection_Types.term ->
            Fstarcompiler.FStarC_Reflection_Types.universe ->
              Fstarcompiler.FStarC_Reflection_V2_Data.var ->
                Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost ->
                  Fstarcompiler.FStarC_TypeChecker_Core.tot_or_ghost ->
                    (unit, unit, unit) typing ->
                      (unit, unit, unit) typing ->
                        (unit, unit, unit) typing ->
                          (unit, unit, unit) typing ->
                            (unit, unit, unit) typing)
  =
  fun g ->
    fun scrutinee ->
      fun then_ ->
        fun else_ ->
          fun ty ->
            fun u_ty ->
              fun hyp ->
                fun eff ->
                  fun ty_eff ->
                    fun ts ->
                      fun tt ->
                        fun te ->
                          fun tr ->
                            let brt =
                              ((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                  Fstarcompiler.FStarC_Reflection_V2_Data.C_True),
                                then_) in
                            let bre =
                              ((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                  Fstarcompiler.FStarC_Reflection_V2_Data.C_False),
                                else_) in
                            let brty uu___ =
                              BT_S
                                (((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                     Fstarcompiler.FStarC_Reflection_V2_Data.C_True),
                                   then_), [],
                                  (BO
                                     ((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                         Fstarcompiler.FStarC_Reflection_V2_Data.C_True),
                                       [], hyp, then_, (), tt)),
                                  [((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                       Fstarcompiler.FStarC_Reflection_V2_Data.C_False),
                                     else_)], [[]],
                                  (BT_S
                                     (((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                          Fstarcompiler.FStarC_Reflection_V2_Data.C_False),
                                        else_), [],
                                       (BO
                                          ((Fstarcompiler.FStarC_Reflection_V2_Data.Pat_Constant
                                              Fstarcompiler.FStarC_Reflection_V2_Data.C_False),
                                            [], hyp, else_, (), te)), [], [],
                                       BT_Nil))) in
                            T_Match
                              (g, u_zero, bool_ty, scrutinee,
                                Fstarcompiler.FStarC_TypeChecker_Core.E_Total,
                                (T_FVar (g, bool_fv)), eff, ts, [brt; bre],
                                (eff, ty), [[]; []],
                                (MC_Tok
                                   (g, scrutinee, bool_ty,
                                     (FStar_List_Tot_Base.map
                                        FStar_Pervasives_Native.fst
                                        [brt; bre]), [[]; []], ())),
                                (brty ()))
let (mk_checked_let :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.name ->
      Prims.string ->
        Fstarcompiler.FStarC_Reflection_Types.term ->
          Fstarcompiler.FStarC_Reflection_Types.typ ->
            (unit, unit) sigelt_for)
  =
  fun g ->
    fun cur_module ->
      fun nm ->
        fun tm ->
          fun ty ->
            let fv =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
                (FStar_List_Tot_Base.op_At cur_module [nm]) in
            let lb =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_lb
                {
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_fv = fv;
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_us = [];
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_typ = ty;
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_def = tm
                } in
            let se =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_sigelt
                (Fstarcompiler.FStarC_Reflection_V2_Data.Sg_Let (false, [lb])) in
            let pf = ST_Let (g, fv, ty, tm, ()) in
            (true, se, FStar_Pervasives_Native.None)
let (mk_unchecked_let :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.name ->
      Prims.string ->
        Fstarcompiler.FStarC_Reflection_Types.term ->
          Fstarcompiler.FStarC_Reflection_Types.typ ->
            (Prims.bool * Fstarcompiler.FStarC_Reflection_Types.sigelt * blob
              FStar_Pervasives_Native.option))
  =
  fun g ->
    fun cur_module ->
      fun nm ->
        fun tm ->
          fun ty ->
            let fv =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_fv
                (FStar_List_Tot_Base.op_At cur_module [nm]) in
            let lb =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_lb
                {
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_fv = fv;
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_us = [];
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_typ = ty;
                  Fstarcompiler.FStarC_Reflection_V2_Data.lb_def = tm
                } in
            let se =
              Fstarcompiler.FStarC_Reflection_V2_Builtins.pack_sigelt
                (Fstarcompiler.FStarC_Reflection_V2_Data.Sg_Let (false, [lb])) in
            (false, se, FStar_Pervasives_Native.None)
let (typing_to_token :
  Fstarcompiler.FStarC_Reflection_Types.env ->
    Fstarcompiler.FStarC_Reflection_Types.term ->
      comp_typ ->
        (unit, unit, unit) typing ->
          (unit, unit, unit)
            Fstarcompiler.FStarC_Tactics_Types_Reflection.typing_token)
  = fun g -> fun e -> fun c -> fun uu___ -> Prims.magic ()
