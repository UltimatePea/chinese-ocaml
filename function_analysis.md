# 功能分析报告 - Poetry艺术评估模块整合

=== src/poetry/artistic_advanced_analysis.ml ===
20:let poetic_critique verse form =
35:let poetic_aesthetics_guidance verse form =
51:let calculate_overall_score report =
59:let analyze_artistic_progression verses =
71:let compare_artistic_quality verse1 verse2 =
85:let detect_artistic_flaws verse =
99:module ArtisticStandards = struct
146:module IntelligentEvaluator = struct

=== src/poetry/artistic_analysis_engine.ml ===
7:let analyze_text_artistic_elements (text : string) : (word_category * string list) list query_result
33:let get_nature_imagery () : string list query_result =
49:let get_seasonal_imagery (season : string) : string list query_result =
60:let suggest_imagery_for_theme (theme : string) : string list query_result =
73:let get_popular_words (category : word_category) (limit : int) : (string * int) list query_result =
90:let get_artistic_trends () : (word_category * float) list query_result =

=== src/poetry/artistic_core_evaluators.ml ===
13:module RhymeGroupSet = Set.Make(struct
22:let contains_substring text pattern =
42:let count_imagery_words verse =
48:let count_elegant_words verse =
68:let evaluate_rhyme_harmony verse =
100:let evaluate_tonal_balance verse expected_pattern =
137:let evaluate_parallelism left_verse right_verse =
185:let evaluate_imagery verse =
196:let evaluate_rhythm verse =
224:let evaluate_elegance verse =
239:let determine_overall_grade scores =
254:let comprehensive_artistic_evaluation verse expected_pattern =

=== src/poetry/artistic_core_types.ml ===
5:type word_category = Imagery | Elegant | Metaphor | Emotion | Nature | Classical
7:type evaluation_dimension =
16:type word_info = {
26:type evaluation_standard = {
36:type artistic_template = {
44:type 'a query_result = Found of 'a | NotFound | QueryError of string
48:let word_category_from_string = function
57:let evaluation_dimension_from_string = function
67:let get_all_evaluation_dimensions () : evaluation_dimension list =

=== src/poetry/artistic_data_accessor.ml ===
9:type word_category = Artistic_core_types.word_category =
17:type evaluation_dimension = Artistic_core_types.evaluation_dimension =
26:type word_info = Artistic_core_types.word_info = {
36:type evaluation_standard = Artistic_core_types.evaluation_standard = {
46:type artistic_template = Artistic_core_types.artistic_template = {
54:type 'a query_result = 'a Artistic_core_types.query_result =
60:let initialize = Artistic_data_registry.initialize
62:let is_initialized = Artistic_data_registry.is_initialized
63:let register_custom_word_source = Artistic_data_registry.register_custom_word_source
66:let get_word_info = Artistic_query_engine.get_word_info
68:let get_words_by_category = Artistic_query_engine.get_words_by_category
69:let search_words_by_pattern = Artistic_query_engine.search_words_by_pattern
70:let get_high_value_words = Artistic_query_engine.get_high_value_words
73:let get_imagery_keywords = Artistic_legacy_compat.get_imagery_keywords
75:let get_nature_imagery = Artistic_analysis_engine.get_nature_imagery
76:let get_seasonal_imagery = Artistic_analysis_engine.get_seasonal_imagery
77:let suggest_imagery_for_theme = Artistic_analysis_engine.suggest_imagery_for_theme
80:let get_elegant_words = Artistic_legacy_compat.get_elegant_words
82:let get_classical_expressions = Artistic_legacy_compat.get_classical_expressions
83:let get_formal_particles = Artistic_legacy_compat.get_formal_particles
84:let assess_word_elegance = Artistic_evaluation_engine.assess_word_elegance
87:let get_evaluation_standards = Artistic_query_engine.get_evaluation_standards
89:let get_all_evaluation_dimensions = Artistic_core_types.get_all_evaluation_dimensions
90:let get_standard_weights = Artistic_evaluation_engine.get_standard_weights
91:let validate_evaluation_criteria = Artistic_evaluation_engine.validate_evaluation_criteria
94:let get_artistic_templates = Artistic_template_manager.get_templates
96:let suggest_template_for_context = Artistic_template_manager.suggest_template_for_context
97:let evaluate_template_effectiveness = Artistic_template_manager.evaluate_template_effectiveness
100:let analyze_text_artistic_elements = Artistic_analysis_engine.analyze_text_artistic_elements
102:let suggest_improvements = Artistic_evaluation_engine.suggest_improvements
103:let calculate_artistic_score = Artistic_evaluation_engine.calculate_artistic_score
104:let compare_artistic_quality = Artistic_evaluation_engine.compare_artistic_quality
107:let get_word_category_statistics = Artistic_query_engine.get_word_category_statistics
109:let get_popular_words = Artistic_analysis_engine.get_popular_words
110:let get_artistic_trends = Artistic_analysis_engine.get_artistic_trends
113:let load_imagery_data = Artistic_legacy_compat.load_imagery_data
115:let load_elegant_data = Artistic_legacy_compat.load_elegant_data
116:let check_word_availability = Artistic_legacy_compat.check_word_availability
119:let format_query_error = Artistic_data_registry.format_query_error
121:let validate_data_integrity = Artistic_data_registry.validate_data_integrity
122:let get_cache_status = Artistic_data_registry.get_cache_status
123:let diagnose_performance = Artistic_data_registry.diagnose_performance

=== src/poetry/artistic_data_loader.ml ===
14:let read_file_safely filepath =
30:let find_json_section content category_name =
57:let extract_words_from_category content category_name =
64:let supported_categories =
88:let load_words_from_json_file filepath =
102:let natural_imagery_keywords = [
108:let emotional_imagery_keywords = [
114:let cultural_imagery_keywords = [
120:let default_imagery_keywords =
124:let default_elegant_words =
161:let imagery_keywords =
168:let elegant_words =
177:let get_imagery_keywords () = Lazy.force imagery_keywords
180:let get_elegant_words () = Lazy.force elegant_words

=== src/poetry/artistic_data_parser.ml ===
7:let parse_word_info_from_json (json : Yojson.Basic.t) : (string * word_info) list =
42:let parse_evaluation_standards_from_json (json : Yojson.Basic.t) :
73:let parse_artistic_templates_from_json (json : Yojson.Basic.t) :

=== src/poetry/artistic_data_registry.ml ===
7:let initialized = ref false
8:let imagery_data_source = "artistic_imagery_data"
9:let elegant_data_source = "artistic_elegant_data"
10:let evaluation_standards_source = "artistic_evaluation_standards"
11:let templates_source = "artistic_templates"
12:let word_info_source = "artistic_word_info"
16:let initialize () =
37:let is_initialized () = !initialized
39:let register_custom_word_source (name : string) (filepath : string) =
45:let format_query_error (error_msg : string) : string = "艺术数据查询错误: " ^ error_msg
47:let validate_data_integrity () : (string * bool * string option) list =
51:let get_cache_status () : (string * bool * int) list =
56:let diagnose_performance () : string =

=== src/poetry/artistic_evaluation.ml ===
13:module Evaluators = Artistic_evaluators
14:module FormsEvaluation = Poetry_forms_evaluation
15:module Guidance = Artistic_guidance
18:let evaluate_rhyme_harmony = Artistic_evaluators.evaluate_rhyme_harmony
19:let evaluate_tonal_balance = Artistic_evaluators.evaluate_tonal_balance
20:let evaluate_parallelism = Artistic_evaluators.evaluate_parallelism
21:let evaluate_imagery = Artistic_evaluators.evaluate_imagery
22:let evaluate_rhythm = Artistic_evaluators.evaluate_rhythm
23:let evaluate_elegance = Artistic_evaluators.evaluate_elegance
26:let convert_artistic_to_evaluation (scores : Poetry_core.Types.artistic_scores) :
38:let convert_grade_to_eval_grade = function
44:let determine_overall_grade (scores : Poetry_core.Types.artistic_scores) :
50:let generate_improvement_suggestions = Artistic_guidance.generate_improvement_suggestions
51:let comprehensive_artistic_evaluation = Artistic_guidance.comprehensive_artistic_evaluation
52:let poetic_critique = Artistic_guidance.poetic_critique
53:let poetic_aesthetics_guidance = Artistic_guidance.poetic_aesthetics_guidance
54:let evaluate_wuyan_lushi = Poetry_forms_evaluation.evaluate_wuyan_lushi
55:let evaluate_qiyan_jueju = Poetry_forms_evaluation.evaluate_qiyan_jueju
56:let evaluate_siyan_parallel_prose = Poetry_forms_evaluation.evaluate_siyan_parallel_prose
57:let evaluate_poetry_by_form = Poetry_forms_evaluation.evaluate_poetry_by_form
60:let () = ()

=== src/poetry/artistic_evaluation_engine.ml ===
7:let get_standard_weights () : (evaluation_dimension * float) list query_result =
21:let validate_evaluation_criteria (dimension : evaluation_dimension) (criteria_text : string) :
42:let calculate_artistic_score (text : string) : (evaluation_dimension * float) list query_result =
62:let compare_artistic_quality (text1 : string) (text2 : string) :
82:let suggest_improvements (_ : string) (focus_dimension : evaluation_dimension) :
98:let assess_word_elegance (word : string) : float query_result =

