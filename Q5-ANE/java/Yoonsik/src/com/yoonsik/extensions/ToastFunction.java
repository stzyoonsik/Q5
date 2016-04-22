package com.yoonsik.extensions;

import android.widget.Toast;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
 
public class ToastFunction implements FREFunction {
 
    @Override
    public FREObject call(FREContext arg0, FREObject[] arg1) {
        // TODO Auto-generated method stub
        CharSequence message = "";
        try {
            message = arg1[0].getAsString();
        } catch (IllegalStateException e) {
            // TODO: handle exception
            e.printStackTrace();
        } catch (FRETypeMismatchException e) {
            // TODO: handle exception
            e.printStackTrace();
        } catch (FREInvalidObjectException e) {
            // TODO: handle exception
            e.printStackTrace();
        } catch (FREWrongThreadException e) {
            // TODO: handle exception
            e.printStackTrace();
        }
        Toast.makeText(arg0.getActivity(), message, Toast.LENGTH_SHORT).show();
        return null;
    }
 
}