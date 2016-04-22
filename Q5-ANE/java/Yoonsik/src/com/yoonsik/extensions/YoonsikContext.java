package com.yoonsik.extensions;
import java.util.HashMap;
import java.util.Map;
 
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
 
public class YoonsikContext extends FREContext {
 
    @Override
    public void dispose() {
        // TODO Auto-generated method stub
 
    }
 
    @Override
    public Map<String, FREFunction> getFunctions() {
        // TODO Auto-generated method stub
        Map<String, FREFunction> map = new HashMap<String, FREFunction>();
        map.put("toast", new ToastFunction());
        map.put("alert", new AlertFunction());
        map.put("selectImage", new SelectImageFunction());
        return map;
    }
 
}