package com.lomo.demo;


import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.util.ArrayList;
import java.util.List;

public class GsonUtils {

    private static Gson gson;
    private static Gson excludeGson;
    static {
        gson = new Gson();
        excludeGson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create();
//        excludeGson = new GsonBuilder().
//                registerTypeAdapter(Class.class, new ClassCodec())
//                .create();
    }

    public static <T> T jsonToBean(String gsonString, Class<T> cls) {
        T t = null;
        if (gson != null) {
            t = gson.fromJson(gsonString, cls);
        }
        return t;
    }

    /**
     * 序列化排除自定义字段
     * @param object
     * @return
     */
    public static String beanToExposeJson(Object object) {
        String gsonString = null;
        if (excludeGson != null) {
            gsonString = excludeGson.toJson(object);
        }
        return gsonString;
    }
    public static String beanToJson(Object object) {
        String gsonString = null;
        if (gson != null) {
            gsonString = gson.toJson(object);
        }
        return gsonString;
    }

    /**
     * 转成list
     * 解决泛型问题
     *
     * @param json json
     * @param cls  类
     * @param <T>  T
     * @return T列表
     */
    public static <T> List<T> jsonToList(String json, Class<T> cls) {
        Gson gson = new Gson();
        List<T> list = new ArrayList<>();
        JsonArray array = new JsonParser().parse(json).getAsJsonArray();
        for (final JsonElement elem : array) {
            list.add(gson.fromJson(elem, cls));
        }
        return list;
    }
}
