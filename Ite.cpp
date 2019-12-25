#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/ADT/APInt.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Attributes.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include "llvm/IR/GlobalValue.h"





using namespace llvm;
namespace{

struct Ite : public FunctionPass
 {
  Function *callee;
  APInt x;
  int f;
  static char ID;

  Ite() : FunctionPass(ID) {}
  virtual bool runOnFunction(Function &F)
  {

            for(Function::iterator block=F.begin();block!=F.end();++block){
                for(BasicBlock::iterator ins=block->begin();ins!=block->end();++ins){
                      Instruction * inst=ins;
                      Function *CF;
                      CallInst *call;
                      bool test=true;
                      if(isa<CallInst>(ins)){
                           call=dyn_cast<CallInst>(inst);
                           CF=call->getCalledFunction();//this is step 1;here we get the called function as step 1
                           errs()<<*CF;
                           int i=0;
                           for(inst_iterator bb=inst_begin(CF),e=inst_end(CF);bb!=e;++bb){
                               i++;
                               for(Function::arg_iterator iter=CF->arg_begin();iter!=CF->arg_end();++iter){//here we check if the function meets the requirements of inlining as step2&3
                                      bool cons=true;
                                      if (isa<Constant>(*iter)) cons=false;//check if arguments are constants
                                      test=test && cons;
                               }
                           }                      
                           if (i>10|| i==0) test=false;//check the amount of instructions
                           if (!test) errs()<<"Not satisfied the requirement."<<'\n'<<"****************"<<'\n';
                           else{
                            errs()<<"Inlining."<<'\n'<<"****************"<<'\n';
/*start modifying the arguments,as step 4&5*/
                            int a=0;
                            for(Function::arg_iterator constArg=CF->arg_begin();constArg!=CF->arg_end();++constArg){
                                 Value* argument=call->getArgOperand(a);       
                                 Constant *b=(Constant *) argument;
                                 x=b->getUniqueInteger();
                                 Constant *rep=ConstantInt::get(constArg->getType(),x);
                                 constArg->replaceAllUsesWith(rep);//replace the uses of arguments with constant we created
                            }   
              
                            llvm::ValueToValueMapTy vmap;
                            if (CF !=NULL&&!CF->isDeclaration()){
                                   for(Function::iterator j=CF->begin();j!=CF->end();++j){
                                          for(BasicBlock::iterator ig=j->begin();ig!=j->end();++ig){
 
                                                  if(isa<ReturnInst>(ig)) continue;
                                                  Instruction *new_inst=ig->clone();
                                                  new_inst->insertBefore(inst);
                                                  vmap[ig]=new_inst;
                                                  llvm::RemapInstruction(new_inst,vmap,RF_NoModuleLevelChanges);
                                          }
                                   }
                            }
                            if (CF !=NULL&&!CF->isDeclaration()){
                                  for(Function::iterator j=CF->begin();j!=CF->end();++j){
                                        for(BasicBlock::iterator ig=j->begin();ig!=j->end();++ig){
           
                                                  if (ReturnInst *temp_return_inst=dyn_cast<ReturnInst>(&*ig)){
                                                          Instruction *inst2=++ins;
                                                          Instruction *inst3=--ins;
                                                          if(temp_return_inst->getNumOperands()!=0){
                                                                   Value *return_value=temp_return_inst->getReturnValue();
                                                                   call->replaceAllUsesWith(vmap[return_value]);
                                                          }
                                                  
                                                  --ins;
                                                  inst3->eraseFromParent();
                                                  }
                                        }
                                  }
                            }
                           }
                      }
            
                }
            }
   //     }    
  //   }
  return true;
  }
 };


}
 

char Ite::ID = 0;
static RegisterPass<Ite> X("Ite", "Iterate Pass", false, false);



