LoaderMaker_from_CCB
====================

 CocosBuilderのファイル(.ccbファイル)から、Loaderのファイルを作成します。

## 使用方法

1. すべての .rb ファイルを [ここ](https://github.com/kohashi/LoaderMaker_from_CCB/archive/master.zip "zip download") からダウンロードしてください。
2. load_maker.rb をエディタで開いてください。
3. あなたの環境にあわせていくつか設定してください。
4. "ruby load_maker.rb" コマンドを実行してください。
5. プロジェクトに "LoadFunc.h" / "LoadFunc.cpp" のファイルを追加してください。
6. AppDelegete.cpp を以下のように編集してください:

 bool AppDelegate::applicationDidFinishLaunching()
 
```cpp
    CCNodeLoaderLibrary* ccNodeLoaderLibrary = CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary();
    LoadFunc::registerLoader(); 
```


## 出力内容詳細


LoadFunc.h

```cpp
#include "cocos2d.h"
#include "cocos-ext.h"

#ifndef __projName__LoadFunc__
#define __projName__LoadFunc__

// include section ------------ 
  #include "YourCCBNoode.h"



// Loader define section ------------ 
      //-----------------------------------
      //../CCB/module/MyCCBLayer.ccb
      #ifdef __projName__MYCCBLayer__
      class MYCCBNodeLoader : public extension::CCLayerLoader {
       public:    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(MYCCBLayerLoader, loader);
       protected: CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(MYCCBLayer);
      };
      #endif




// loader function section ------------ 
      class LoadFunc{
        public: static void registerLoader(){
          CCNodeLoaderLibrary* ccNodeLoaderLibrary = CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary();
          #ifdef __projName__MYCCBLayer__
            ccNodeLoaderLibrary->registerCCNodeLoader("MYCCBLayer", MYCCBLayerLoader::loader());
          #endif
        }
      };
#endif //__projName__LoadFunc__)

```









LoadFunc.cpp

```cpp
 #include "LoadFunc.h"
      //-----------------------------------
    //../CCB/module/MyCCBLayer.ccb
    #ifdef __projName__MYCCBLayer__
    bool MYCCBLayer::onAssignCCBMemberVariable(CCObject* pTarget, const char* pMemberVariableName, CCNode* pNode)
    {
      //doc_root_var 
       CCB_MEMBERVARIABLEASSIGNER_GLUE(this, "labelTitle", CCLabelTTF *, this->m_labelTitle);
       CCB_MEMBERVARIABLEASSIGNER_GLUE(this, "buyButton", CCSprite *, this->m_buyButton);
	      return false;
    }

    SEL_MenuHandler MYCCBLayer::onResolveCCBCCMenuItemSelector(CCObject * pTarget, const char* pSelectorName) {
      //cc_menu 
      CCB_SELECTORRESOLVER_CCMENUITEM_GLUE(this, "pushYES:", MYCCBLayer::pushYES);
      CCB_SELECTORRESOLVER_CCMENUITEM_GLUE(this, "pushNO:", MYCCBLayer::pushNO);
      return NULL;
    };

    SEL_CCControlHandler MYCCBLayer::onResolveCCBCCControlSelector(CCObject * pTarget, const char* pSelectorName) {
      //cc_control 
      CCB_SELECTORRESOLVER_CCCONTROL_GLUE(this, "toNext:", MYCCBLayer::toNext);
      CCB_SELECTORRESOLVER_CCCONTROL_GLUE(this, "toBack:", MYCCBLayer::toBack);
      return NULL;
    };
    #endif
```






