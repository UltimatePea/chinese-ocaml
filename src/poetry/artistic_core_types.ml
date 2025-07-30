(* 艺术数据核心类型定义模块 *)

(** {1 艺术数据核心类型定义} *)

type word_category =
  | Imagery           
  | Elegant           
  | Metaphor          
  | Emotion           
  | Nature            
  | Classical         

type evaluation_dimension =
  | RhymeHarmony      
  | TonalBalance      
  | Parallelism       
  | ImageryDepth      
  | FormBeauty        
  | ContentDepth      
  | MoodContext       

type word_info = {
  word : string;                    
  category : word_category;         
  frequency : int;                  
  artistic_value : float;           
  synonyms : string list;           
  contexts : string list;           
  examples : string list;           
}

type evaluation_standard = {
  dimension : evaluation_dimension; 
  name : string;                    
  description : string;             
  weight : float;                   
  min_score : float;                
  max_score : float;                
  criteria : (string * float) list; 
}

type artistic_template = {
  name : string;                    
  category : word_category;         
  pattern : string;                 
  examples : string list;           
  effectiveness : float;            
}

type 'a query_result = 
  | Found of 'a
  | NotFound
  | QueryError of string

(** {1 类型转换函数} *)

let word_category_from_string = function
  | "意象" | "imagery" -> Imagery
  | "雅致" | "elegant" -> Elegant
  | "比喻" | "metaphor" -> Metaphor
  | "情感" | "emotion" -> Emotion
  | "自然" | "nature" -> Nature
  | "古典" | "classical" -> Classical
  | _ -> Imagery

let evaluation_dimension_from_string = function
  | "韵律和谐度" | "rhyme_harmony" -> RhymeHarmony
  | "声调平衡度" | "tonal_balance" -> TonalBalance
  | "对仗工整度" | "parallelism" -> Parallelism
  | "意象深度" | "imagery_depth" -> ImageryDepth
  | "形式美感" | "form_beauty" -> FormBeauty
  | "内容深度" | "content_depth" -> ContentDepth
  | "意境营造" | "mood_context" -> MoodContext
  | _ -> ImageryDepth

let get_all_evaluation_dimensions () : evaluation_dimension list =
  [RhymeHarmony; TonalBalance; Parallelism; ImageryDepth; FormBeauty; ContentDepth; MoodContext]