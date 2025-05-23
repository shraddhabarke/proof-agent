open Fstarcompiler
open Prims
let (compare_name :
  Fstarcompiler.FStarC_Reflection_Types.name ->
    Fstarcompiler.FStarC_Reflection_Types.name -> FStar_Order.order)
  =
  fun n1 ->
    fun n2 ->
      FStar_Order.compare_list n1 n2
        (fun s1 ->
           fun s2 ->
             FStar_Order.order_from_int
               (Fstarcompiler.FStarC_Reflection_V2_Builtins.compare_string s1
                  s2))
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_name" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_name"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     (Fstarcompiler.FStarC_Syntax_Embeddings.e_list
                        Fstarcompiler.FStarC_Syntax_Embeddings.e_string)
                     (Fstarcompiler.FStarC_Syntax_Embeddings.e_list
                        Fstarcompiler.FStarC_Syntax_Embeddings.e_string)
                     FStar_Order.e_order compare_name
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_name") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_name"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_list
                      Fstarcompiler.FStarC_TypeChecker_NBETerm.e_string)
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_list
                      Fstarcompiler.FStarC_TypeChecker_NBETerm.e_string)
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_name
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_name") cb us) args))
let (compare_fv :
  Fstarcompiler.FStarC_Reflection_Types.fv ->
    Fstarcompiler.FStarC_Reflection_Types.fv -> FStar_Order.order)
  =
  fun f1 ->
    fun f2 ->
      compare_name
        (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_fv f1)
        (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_fv f2)
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_fv" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_fv"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_fv
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_fv
                     FStar_Order.e_order compare_fv
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_fv") cb us) args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_fv"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_fv
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_fv
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_fv
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_fv") cb us) args))
let (compare_const :
  Fstarcompiler.FStarC_Reflection_V2_Data.vconst ->
    Fstarcompiler.FStarC_Reflection_V2_Data.vconst -> FStar_Order.order)
  =
  fun c1 ->
    fun c2 ->
      match (c1, c2) with
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Unit,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Unit) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Int i,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Int j) ->
          FStar_Order.order_from_int (i - j)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_True,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_True) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_False,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_False) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_String s1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_String s2) ->
          FStar_Order.order_from_int
            (Fstarcompiler.FStarC_Reflection_V2_Builtins.compare_string s1 s2)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Range r1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Range r2) ->
          FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Reify,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Reify) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Reflect l1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Reflect l2) ->
          compare_name l1 l2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Real r1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Real r2) ->
          FStar_Order.order_from_int
            (Fstarcompiler.FStarC_Reflection_V2_Builtins.compare_string r1 r2)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Unit, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Unit) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Int uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Int uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_True, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_True) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_False, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_False) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_String uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_String uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Range uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Range uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Reify, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Reify) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Reflect uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Reflect uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Real uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Real uu___1) ->
          FStar_Order.Gt
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_const" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_const"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_vconst
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_vconst
                     FStar_Order.e_order compare_const
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_const") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_const"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_vconst
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_vconst
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_const
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_const") cb us)
                  args))
let (compare_ident :
  Fstarcompiler.FStarC_Reflection_Types.ident ->
    Fstarcompiler.FStarC_Reflection_Types.ident -> FStar_Order.order)
  =
  fun i1 ->
    fun i2 ->
      let uu___ =
        Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ident i1 in
      match uu___ with
      | (nm1, uu___1) ->
          let uu___2 =
            Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ident i2 in
          (match uu___2 with
           | (nm2, uu___3) ->
               FStar_Order.order_from_int
                 (Fstarcompiler.FStarC_Reflection_V2_Builtins.compare_string
                    nm1 nm2))
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_ident" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_ident"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_ident
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_ident
                     FStar_Order.e_order compare_ident
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_ident") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_ident"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_ident
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_ident
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_ident
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_ident") cb us)
                  args))
let rec (compare_universe :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.universe -> FStar_Order.order)
  =
  fun u1 ->
    fun u2 ->
      match ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_universe u1),
              (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_universe
                 u2))
      with
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Zero,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Zero) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Succ u11,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Succ u21) ->
          compare_universe u11 u21
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Max us1,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Max us2) ->
          FStar_Order.compare_list us1 us2
            (fun x -> fun y -> compare_universe x y)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_BVar n1,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_BVar n2) ->
          FStar_Order.compare_int n1 n2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Name i1,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Name i2) ->
          compare_ident i1 i2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unif u11,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unif u21) ->
          FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unk,
         Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unk) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Zero, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Zero) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Succ uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Succ uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Max uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Max uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_BVar uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_BVar uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Name uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Name uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unif uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unif uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Uv_Unk, uu___) ->
          FStar_Order.Lt
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_universe" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_universe"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe
                     FStar_Order.e_order compare_universe
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_universe") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_universe"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_universe
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_universe") cb us)
                  args))
let (compare_universes :
  Fstarcompiler.FStarC_Reflection_V2_Data.universes ->
    Fstarcompiler.FStarC_Reflection_V2_Data.universes -> FStar_Order.order)
  = fun us1 -> fun us2 -> FStar_Order.compare_list us1 us2 compare_universe
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_universes" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_universes"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     (Fstarcompiler.FStarC_Syntax_Embeddings.e_list
                        Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe)
                     (Fstarcompiler.FStarC_Syntax_Embeddings.e_list
                        Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe)
                     FStar_Order.e_order compare_universes
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_universes") cb
                     us) args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_universes"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_list
                      Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe)
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_list
                      Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe)
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_universes
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_universes") cb us)
                  args))
let rec (__compare_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_Types.term -> FStar_Order.order)
  =
  fun s ->
    fun t ->
      match ((Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln s),
              (Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_ln t))
      with
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var sv,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var tv) ->
          FStar_Reflection_V2_Derived.compare_namedv sv tv
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar sv,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar tv) ->
          FStar_Reflection_V2_Derived.compare_bv sv tv
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar sv,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar tv) ->
          compare_fv sv tv
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (sv, sus),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (tv, tus)) ->
          FStar_Order.lex (compare_fv sv tv)
            (fun uu___ -> compare_universes sus tus)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (uu___, uu___1),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (uu___2, uu___3)) ->
          let uu___4 = FStar_Reflection_V2_Derived_Lemmas.collect_app_ref s in
          (match uu___4 with
           | (h1, aa1) ->
               let uu___5 =
                 FStar_Reflection_V2_Derived_Lemmas.collect_app_ref t in
               (match uu___5 with
                | (h2, aa2) ->
                    FStar_Order.lex (__compare_term h1 h2)
                      (fun uu___6 -> compare_argv_list () () aa1 aa2)))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (b1, e1),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (b2, e2)) ->
          FStar_Order.lex (__compare_binder b1 b2)
            (fun uu___ -> __compare_term e1 e2)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (b1, e1),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (b2, e2)) ->
          FStar_Order.lex (__compare_binder b1 b2)
            (fun uu___ -> __compare_term e1 e2)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (b1, e1),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (b2, e2)) ->
          FStar_Order.lex (__compare_binder b1 b2)
            (fun uu___ -> __compare_comp e1 e2)
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type su,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type tu) ->
          compare_universe su tu
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const c1,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const c2) ->
          compare_const c1 c2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (u1, uu___),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (u2, uu___1)) ->
          FStar_Order.compare_int u1 u2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
         (_r1, _attrs1, b1, t1, t1'),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
         (_r2, _attrs2, b2, t2, t2')) ->
          FStar_Order.lex (__compare_binder b1 b2)
            (fun uu___ ->
               FStar_Order.lex (__compare_term t1 t2)
                 (fun uu___1 -> __compare_term t1' t2'))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
         (uu___, uu___1, uu___2),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
         (uu___3, uu___4, uu___5)) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT
         (e1, t1, tac1, uu___),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT
         (e2, t2, tac2, uu___1)) ->
          FStar_Order.lex (__compare_term e1 e2)
            (fun uu___2 ->
               FStar_Order.lex (__compare_term t1 t2)
                 (fun uu___3 ->
                    match (tac1, tac2) with
                    | (FStar_Pervasives_Native.None,
                       FStar_Pervasives_Native.None) -> FStar_Order.Eq
                    | (FStar_Pervasives_Native.None, uu___4) ->
                        FStar_Order.Lt
                    | (uu___4, FStar_Pervasives_Native.None) ->
                        FStar_Order.Gt
                    | (FStar_Pervasives_Native.Some e11,
                       FStar_Pervasives_Native.Some e21) ->
                        __compare_term e11 e21))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC
         (e1, c1, tac1, uu___),
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC
         (e2, c2, tac2, uu___1)) ->
          FStar_Order.lex (__compare_term e1 e2)
            (fun uu___2 ->
               FStar_Order.lex (__compare_comp c1 c2)
                 (fun uu___3 ->
                    match (tac1, tac2) with
                    | (FStar_Pervasives_Native.None,
                       FStar_Pervasives_Native.None) -> FStar_Order.Eq
                    | (FStar_Pervasives_Native.None, uu___4) ->
                        FStar_Order.Lt
                    | (uu___4, FStar_Pervasives_Native.None) ->
                        FStar_Order.Gt
                    | (FStar_Pervasives_Native.Some e11,
                       FStar_Pervasives_Native.Some e21) ->
                        __compare_term e11 e21))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown) ->
          FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp,
         Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp) -> FStar_Order.Eq
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Var uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_BVar uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_FVar uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_UInst
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_App
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Abs
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Arrow
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Type uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Refine
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Const uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar (uu___, uu___1),
         uu___2) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Uvar
         (uu___1, uu___2)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
         (uu___, uu___1, uu___2, uu___3, uu___4), uu___5) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Let
         (uu___1, uu___2, uu___3, uu___4, uu___5)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
         (uu___, uu___1, uu___2), uu___3) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Match
         (uu___1, uu___2, uu___3)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT
         (uu___, uu___1, uu___2, uu___3), uu___4) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedT
         (uu___1, uu___2, uu___3, uu___4)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC
         (uu___, uu___1, uu___2, uu___3), uu___4) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_AscribedC
         (uu___1, uu___2, uu___3, uu___4)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unknown) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp, uu___) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.Tv_Unsupp) ->
          FStar_Order.Gt
and (__compare_term_list :
  Fstarcompiler.FStarC_Reflection_Types.term Prims.list ->
    Fstarcompiler.FStarC_Reflection_Types.term Prims.list ->
      FStar_Order.order)
  =
  fun l1 ->
    fun l2 ->
      match (l1, l2) with
      | ([], []) -> FStar_Order.Eq
      | ([], uu___) -> FStar_Order.Lt
      | (uu___, []) -> FStar_Order.Gt
      | (hd1::tl1, hd2::tl2) ->
          FStar_Order.lex (__compare_term hd1 hd2)
            (fun uu___ -> __compare_term_list tl1 tl2)
and (compare_argv :
  unit ->
    unit ->
      Fstarcompiler.FStarC_Reflection_V2_Data.argv ->
        Fstarcompiler.FStarC_Reflection_V2_Data.argv -> FStar_Order.order)
  =
  fun b1 ->
    fun b2 ->
      fun a1 ->
        fun a2 ->
          let uu___ = a1 in
          match uu___ with
          | (t1, q1) ->
              let uu___1 = a2 in
              (match uu___1 with
               | (t2, q2) ->
                   (match (q1, q2) with
                    | (Fstarcompiler.FStarC_Reflection_V2_Data.Q_Implicit,
                       Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit) ->
                        FStar_Order.Lt
                    | (Fstarcompiler.FStarC_Reflection_V2_Data.Q_Explicit,
                       Fstarcompiler.FStarC_Reflection_V2_Data.Q_Implicit) ->
                        FStar_Order.Gt
                    | (uu___2, uu___3) -> __compare_term t1 t2))
and (compare_argv_list :
  unit ->
    unit ->
      Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list ->
        Fstarcompiler.FStarC_Reflection_V2_Data.argv Prims.list ->
          FStar_Order.order)
  =
  fun b1 ->
    fun b2 ->
      fun l1 ->
        fun l2 ->
          match (l1, l2) with
          | ([], []) -> FStar_Order.Eq
          | ([], uu___) -> FStar_Order.Lt
          | (uu___, []) -> FStar_Order.Gt
          | (hd1::tl1, hd2::tl2) ->
              FStar_Order.lex (compare_argv () () hd1 hd2)
                (fun uu___ -> compare_argv_list () () tl1 tl2)
and (__compare_comp :
  Fstarcompiler.FStarC_Reflection_Types.comp ->
    Fstarcompiler.FStarC_Reflection_Types.comp -> FStar_Order.order)
  =
  fun c1 ->
    fun c2 ->
      let cv1 = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_comp c1 in
      let cv2 = Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_comp c2 in
      match (cv1, cv2) with
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Total t2) ->
          __compare_term t1 t2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t1,
         Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal t2) ->
          __compare_term t1 t2
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma (p1, q1, s1),
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma (p2, q2, s2)) ->
          FStar_Order.lex (__compare_term p1 p2)
            (fun uu___ ->
               FStar_Order.lex (__compare_term q1 q2)
                 (fun uu___1 -> __compare_term s1 s2))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
         (us1, eff1, res1, args1, _decrs1),
         Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
         (us2, eff2, res2, args2, _decrs2)) ->
          FStar_Order.lex (compare_universes us1 us2)
            (fun uu___ ->
               FStar_Order.lex (compare_name eff1 eff2)
                 (fun uu___1 -> __compare_term res1 res2))
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Total uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Total uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal uu___, uu___1) ->
          FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_GTotal uu___1) ->
          FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma
         (uu___, uu___1, uu___2), uu___3) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Lemma
         (uu___1, uu___2, uu___3)) -> FStar_Order.Gt
      | (Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
         (uu___, uu___1, uu___2, uu___3, uu___4), uu___5) -> FStar_Order.Lt
      | (uu___, Fstarcompiler.FStarC_Reflection_V2_Data.C_Eff
         (uu___1, uu___2, uu___3, uu___4, uu___5)) -> FStar_Order.Gt
and (__compare_binder :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    Fstarcompiler.FStarC_Reflection_Types.binder -> FStar_Order.order)
  =
  fun b1 ->
    fun b2 ->
      let bview1 =
        Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b1 in
      let bview2 =
        Fstarcompiler.FStarC_Reflection_V2_Builtins.inspect_binder b2 in
      __compare_term bview1.Fstarcompiler.FStarC_Reflection_V2_Data.sort2
        bview2.Fstarcompiler.FStarC_Reflection_V2_Data.sort2
let (compare_term :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_Types.term -> FStar_Order.order)
  = __compare_term
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_term" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_term"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_term
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_term
                     FStar_Order.e_order compare_term
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_term") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_term"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_term
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_term
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_term
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_term") cb us) args))
let (compare_comp :
  Fstarcompiler.FStarC_Reflection_Types.comp ->
    Fstarcompiler.FStarC_Reflection_Types.comp -> FStar_Order.order)
  = __compare_comp
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_comp" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_comp"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_comp
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_comp
                     FStar_Order.e_order compare_comp
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_comp") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_comp"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_comp
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_comp
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_comp
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_comp") cb us) args))
let (compare_binder :
  Fstarcompiler.FStarC_Reflection_Types.binder ->
    Fstarcompiler.FStarC_Reflection_Types.binder -> FStar_Order.order)
  = __compare_binder
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.V2.Compare.compare_binder" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.V2.Compare.compare_binder"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_binder
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_binder
                     FStar_Order.e_order compare_binder
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.V2.Compare.compare_binder") cb us)
                    args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.V2.Compare.compare_binder"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_binder
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_binder
                   (Fstarcompiler.FStarC_TypeChecker_NBETerm.e_unsupported ())
                   compare_binder
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.V2.Compare.compare_binder") cb us)
                  args))
