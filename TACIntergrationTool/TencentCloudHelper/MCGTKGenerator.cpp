//
//  MCGTKGenerator.cpp
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 03/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#include "MCGTKGenerator.hpp"
#include <stdlib.h>
//#include "vector.h"
//char* time33(const char* str) {
//    size_t length = strlen(str);
//    long  hash = 5381;
//    for (int i = 0; i < length ; i++) {
//        hash += ( hash << 5 ) + (int)str[i];
//    }
////    return hash & 0x7fffffff;
//}
//
//char* MCGTKGenerator::GenerateCSRF(char* skey, char* pSkey) {
//    int csrf = atoi(time33(skey));
//
//
//}


//var csrf = function(req, res, next) {
//
//    var skey = req.cookies["skey"],
//    p_skey = req.cookies["p_skey"],
//    token = req.query.mc_gtk;
//
//    function $time33(str){
//        for(var i=0,len=str.length,hash=5381;i<len;++i) {
//            hash+=(hash<<5)+str.charAt(i).charCodeAt();
//        };
//        return hash&0x7fffffff;
//    }
//
//    if(!skey && p_skey != null && p_skey != '') {
//        skey = p_skey
//    }
//
//    if(!skey || !token || +token !== $time33(skey)) {
//        return res.status(200).send({
//        code: 1,
//        message: 'token失效'
//        })
//    }
//
//    next()
//}
