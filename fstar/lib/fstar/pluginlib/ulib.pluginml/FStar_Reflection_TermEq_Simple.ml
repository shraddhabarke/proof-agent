open Fstarcompiler
open Prims
let (term_eq :
  Fstarcompiler.FStarC_Reflection_Types.term ->
    Fstarcompiler.FStarC_Reflection_Types.term -> Prims.bool)
  = FStar_Reflection_TermEq.term_eq
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.TermEq.Simple.term_eq" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.TermEq.Simple.term_eq"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_term
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_term
                     Fstarcompiler.FStarC_Syntax_Embeddings.e_bool term_eq
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.TermEq.Simple.term_eq") cb us) args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.TermEq.Simple.term_eq"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_term
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_term
                   Fstarcompiler.FStarC_TypeChecker_NBETerm.e_bool term_eq
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.TermEq.Simple.term_eq") cb us) args))
let (univ_eq :
  Fstarcompiler.FStarC_Reflection_Types.universe ->
    Fstarcompiler.FStarC_Reflection_Types.universe -> Prims.bool)
  = FStar_Reflection_TermEq.univ_eq
let _ =
  Fstarcompiler.FStarC_Tactics_Native.register_plugin
    "FStar.Reflection.TermEq.Simple.univ_eq" (Prims.of_int (2))
    (fun _psc ->
       fun cb ->
         fun us ->
           fun args ->
             Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
               "FStar.Reflection.TermEq.Simple.univ_eq"
               (fun _ ->
                  (Fstarcompiler.FStarC_Syntax_Embeddings.arrow_as_prim_step_2
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe
                     Fstarcompiler.FStarC_Reflection_V2_Embeddings.e_universe
                     Fstarcompiler.FStarC_Syntax_Embeddings.e_bool univ_eq
                     (Fstarcompiler.FStarC_Ident.lid_of_str
                        "FStar.Reflection.TermEq.Simple.univ_eq") cb us) args))
    (fun cb ->
       fun us ->
         fun args ->
           Fstarcompiler.FStarC_Syntax_Embeddings.debug_wrap
             "FStar.Reflection.TermEq.Simple.univ_eq"
             (fun _ ->
                (Fstarcompiler.FStarC_TypeChecker_NBETerm.arrow_as_prim_step_2
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe
                   Fstarcompiler.FStarC_Reflection_V2_NBEEmbeddings.e_universe
                   Fstarcompiler.FStarC_TypeChecker_NBETerm.e_bool univ_eq
                   (Fstarcompiler.FStarC_Ident.lid_of_str
                      "FStar.Reflection.TermEq.Simple.univ_eq") cb us) args))
