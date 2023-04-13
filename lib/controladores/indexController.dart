import 'package:get/get.dart';

class IndexController extends GetxController{
  int indexPage = 0;
  int id_condutor = 0;


  retId(){
    return id_condutor;
  }

  changeIndexPage(value){
    indexPage = value;
    update();
  }

  storeLogin(value){
    id_condutor = value;
    update();
  }

  storeLogout(){
    id_condutor = 0;
    update();
  }

  isLogged(){
    if(id_condutor == 0){
      return false;
    }else{
      return true;
    }
  }

}