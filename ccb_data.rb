# coding: utf-8





# CCBを解析して、.hや.cppの内容を作るクラス
class CCBData
  attr_reader :base_class
  attr_reader :custom_class

  attr_reader:include_guard_start
  attr_reader:include_guard_end


  attr_reader:doc_root_vars
  attr_reader:custom_prop_vars
  attr_reader:cc_menu_item_arr
  attr_reader:cc_control_arr

  def initialize(node_graph)
    @custom_class = ""
    @base_class = ""
    @doc_root_vars = Hash.new
    @custom_prop_vars = Hash.new
    @owner_vars = Hash.new
    @cc_menu_item_arr = Array.new
    @cc_control_arr = Array.new
    @node_graph = node_graph
  end


  def analyse(node_graph=@node_graph)
    __child_search(node_graph["children"]) #子要素を検索
  end



  def get_name()
    @custom_class = @node_graph["customClass"]
    @base_class = @node_graph["baseClass"]

    return @custom_class
  end




  def set_include_guard(guard_name)
    @include_guard_start = "#ifdef #{guard_name}"
    @include_guard_end =   "#endif"
  end


  def __child_search(node_arr)

    #子要素を順次処理
    node_arr.each{|node|

      class_name = node["customClass"]
      if class_name == "" then class_name = node["baseClass"]
      end



      #プロパティをチェック
      ccb_file_name = __check_prop(node["properties"])

      #カスタムプロパティをチェック
      __check_custom_prop(node["customProperties"], class_name)


      if ccb_file_name != ""
        class_name = ccb_file_name
      end
      #割り当て変数をチェック
      case node["memberVarAssignmentType"]
        when 0 # don't assing
          ""
        when 1 # doc root var
          @doc_root_vars[node["memberVarAssignmentName"]] = class_name
        when 2 # owner var
          @owner_vars[node["memberVarAssignmentName"]] = class_name
      end



      #さらに子要素を再帰
      __child_search(node["children"])
    }
  end

  def __check_prop(prop_arr)
    ccb_file_name = ""
    prop_arr.each{|prop|
      if prop["name"] == "block" && prop["type"] == "Block"
        @cc_menu_item_arr.push prop['value'][0]
        #prop['value'][1] の値が1ならdocroot, 2ならowner, 0ならdont assignぽい
      end
      if prop["name"] == "ccControl" && prop["type"] == "BlockCCControl"
        if prop["value"][0] != "" then
          @cc_control_arr.push prop["value"][0]
        end
      end
      if prop["name"] == "ccbFile"
        ccb_file_name = prop["value"]
      end
    }
    return ccb_file_name
  end

  def __check_custom_prop(prop_arr, class_name)
    if prop_arr == nil then return end
    prop_arr.each{|prop|
      #割り当てカスタムプロパティをチェック
      custom_prop = {:className=> class_name, :propName=> prop["name"]}
      case prop["type"]
        when 0 # int
          custom_prop[:type] = "int"
        when 1 # float
          custom_prop[:type] = "float"
        when 2 # bool
          custom_prop[:type] = "bool"
        when 3 # string
          custom_prop[:type] = "string"
      end
      @custom_prop_vars[class_name + prop["name"]] = custom_prop

    }
  end




end
