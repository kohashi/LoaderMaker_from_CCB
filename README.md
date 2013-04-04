LoaderMaker_from_CCB
====================

 A loader file maker from CocosBuilder files(.ccb).

## How to use

1. Download all .rb files from [here](https://github.com/kohashi/LoaderMaker_from_CCB/archive/master.zip "zip download").
2. Open load_maker.rb on your text editor.
3. Edit a few setting as your environment.
4. Run "ruby load_maker.rb" command.
5. Add the "LoadFunc.h" / "LoadFunc.cpp" file to your project.
6. Edit AppDelegete.cpp like as follows:

 bool AppDelegate::applicationDidFinishLaunching()
 
```cpp
    CCNodeLoaderLibrary* ccNodeLoaderLibrary = CCNodeLoaderLibrary::sharedCCNodeLoaderLibrary();
    LoadFunc::registerLoader(); 
```


## Output details


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






