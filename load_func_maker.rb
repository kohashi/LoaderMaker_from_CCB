# coding: utf-8

require 'ccb_data'
require 'plist'




class LoadFuncMaker
  attr_accessor:project_name
  attr_accessor:base_directory

  def initialize(proj_name)
    @project_name = proj_name

    @paths_arr_list = Hash.new
    @ccb_data_list = Hash.new
    @path_class_dic = Hash.new()
    @separator_dic = Hash.new()
  end

  def add_ccb_file(file_path)
    plist = Plist.file_to_plist(file_path)

    lm = CCBData.new(plist["nodeGraph"])
    class_name = lm.get_name() #クラス名取得

    if class_name == "" then return end


    lm.analyse()
    lm.set_include_guard("__#{@project_name}__#{class_name}__")
    relative_path = file_path.slice(@base_directory.length, file_path.length)

    @path_class_dic[relative_path] = class_name

    if class_name != nil
      custom_class = lm.custom_class

      if !@paths_arr_list.key?(custom_class)
        # first register
        @paths_arr_list[custom_class] = [(file_path)]
        @ccb_data_list[custom_class] = lm
        @separator_dic[custom_class] = "//-----------------------------------"
      else
        # already registered
        @paths_arr_list[custom_class].push(file_path)
        @ccb_data_list[custom_class].__child_search(plist["nodeGraph"]["children"])
      end
      @separator_dic[custom_class] += "\n    //"+ file_path
    end
  end


  def output_h_file()

    out_include = "\n\n\n\n// include section ------------ \n"
    out_loader_define = "\n\n\n\n// Loader define section ------------ \n"
    out_loader_func =  "\n\n\n\n// loader function section ------------ \n" + <<-EOS
      class LoadFunc{
        public: static void registerLoader(){
          CCNodeLoaderLibrary* ccNodeLoaderLibrary = CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary();
    EOS

    ##################
    keys = @ccb_data_list.keys.sort
    keys.each{|key|
      class_name = key
      lm = @ccb_data_list[key]

      out_include += "  #include \"#{class_name}.h\"\n"

      out_loader_define += <<-EOS
      #{@separator_dic[lm.custom_class]}
      #{lm.include_guard_start}
      class #{lm.custom_class}Loader : public extension::#{lm.base_class}Loader {
	      public:    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(#{lm.custom_class}Loader, loader);
    	  protected: CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(#{lm.custom_class});
      };
      #{lm.include_guard_end}
      EOS

      out_loader_func +=  <<-EOS
        #{lm.include_guard_start}
          ccNodeLoaderLibrary->registerCCNodeLoader("#{lm.custom_class}", #{lm.custom_class}Loader::loader());
        #{lm.include_guard_end}
      EOS
    }
    ##################

    out_loader_func +=  <<-EOS
        }
      };
    EOS

    include_guard =
      "// ##### 【注意】このファイルは自動生成ファイルですので、変更しないでください ######\n" +
      "// ##### 更新時は、LoaderMaker/LoadMaker.rb のrubyスクリプトを実行してください #####\n" +
      "#ifndef __#{@project_name}__LoadFunc__\n" +
      "#define __#{@project_name}__LoadFunc__\n"

    return include_guard +
          HEADER_START +
            out_include +
            out_loader_define +
            out_loader_func +
          HEADER_END +
          "#endif //__#{@project_name}__LoadFunc__)"
  end

  def output_cpp_file()
    keys = @ccb_data_list.keys.sort
    output = CPP_START
    keys.each{|key|
      lm = @ccb_data_list[key]
      output += get_cpp(lm) #cppファイル書き込み
    }

    return output
  end


  def get_cpp(lm)
    ccb_member_var = "\n"
    var_names = lm.doc_root_vars.keys.sort
    var_names.each{|var_name|
      var_type = lm.doc_root_vars[var_name]
      #check CCB-custom class- type
      ccb_custom_class = @path_class_dic[var_type]
      if ccb_custom_class != nil
        var_type = @path_class_dic[var_type]
      end
      if var_type == nil || var_type == "" || var_type.include?(".ccb")
        var_type = "CCNode"
      end
      ccb_member_var += <<-EOS
	    CCB_MEMBERVARIABLEASSIGNER_GLUE(this, "#{var_name}", #{var_type} *, this->m_#{var_name});
      EOS
    }
    ccb_member_var.chomp!

    ## カスタムプロパティ
    custom_prop = "\n"
    lm.custom_prop_vars.each{|k, v|
      p_type = v[:type]
      p_name = v[:propName]
      p_class_name = v[:className]

      custom_prop += <<-EOS
	    CCB_CUSTOMPROPERTY_GLUE(this, "#{p_name}", pCCBValue->get#{p_type.capitalize}Value());
      EOS
    }
    custom_prop.chomp!

    ## CCMenuItemメソッド
    cc_menu_item = "\n"
    lm.cc_menu_item_arr.each{|sel|
      sel_r = sel.delete(":")
      cc_menu_item += <<-EOS
      CCB_SELECTORRESOLVER_CCMENUITEM_GLUE(this, "#{sel}", #{lm.custom_class}::#{sel_r});
      EOS
    }
    cc_menu_item.chomp!

    ## CCControlメソッド
    cc_control = "\n"
    lm.cc_control_arr.each{|sel|
      sel_r = sel.delete(":")
      cc_control += <<-EOS
      CCB_SELECTORRESOLVER_CCCONTROL_GLUE(this, "#{sel}", #{lm.custom_class}::#{sel_r});
      EOS
    }
    cc_control.chomp!



    #最終出力内容--------
    ret_val = <<-EOS_One_Class
    #{@separator_dic[lm.custom_class]}
    #{lm.include_guard_start}
    bool #{lm.custom_class}::onAssignCCBMemberVariable(CCObject* pTarget, const char* pMemberVariableName, CCNode* pNode)
    {
      //doc_root_var #{ccb_member_var}
	    return false;
    }

    SEL_MenuHandler #{lm.custom_class}::onResolveCCBCCMenuItemSelector(CCObject * pTarget, const char* pSelectorName) {
      //cc_menu #{cc_menu_item}
      return NULL;
    };
    SEL_CCControlHandler #{lm.custom_class}::onResolveCCBCCControlSelector(CCObject * pTarget, const char* pSelectorName) {
      //cc_control #{cc_control}
      return NULL;
    };
    #{lm.include_guard_end}

    EOS_One_Class
    #出力行終わり
    return ret_val
  end



  ##################


  HEADER_START = <<-EOS

#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC;
USING_NS_CC_EXT;



#define CCB_CUSTOMPROPERTY_GLUE(TARGET, MEMBERVARIABLENAME, PROPVALUE) \
if (0 == strcmp(pMemberVariableName, ( #MEMBERVARIABLENAME ))) { \
  TARGET->set ## MEMBERVARIABLENAME (PROPVALUE); \
  return true; \
}

  EOS



  HEADER_END = <<-EOS
  EOS



  CPP_START = <<-EOS
// ##### 【注意】このファイルは自動生成ファイルですので、変更しないでください ######
// ##### 更新時は、LoaderMaker/LoadMaker.rb のrubyスクリプトを実行してください #####

#include "LoadFunc.h"




  EOS


  CPP_END = <<-EOS

  EOS





end




