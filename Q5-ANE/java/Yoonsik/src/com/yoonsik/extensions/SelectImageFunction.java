package com.yoonsik.extensions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.adobe.fre.FREArray;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.widget.Toast;

public class SelectImageFunction implements FREFunction {
	private FREContext _context;
	private String[] _imageName;

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		_context = arg0;
		
		try {
			_imageName = new String[(int)((FREArray)arg1[0]).getLength()];
			
			for(int i=0; i < ((FREArray)arg1[0]).getLength(); ++i)
        	{	
        		
				_imageName[i] = ((FREArray)arg1[0]).getObjectAt(i).getAsString();
        	}
			
			
			
		} catch (IllegalStateException e) {
			// TODO: handle exception
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			// TODO: handle exception
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			// TODO: handle exception
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		AlertDialog.Builder builder = new AlertDialog.Builder(_context.getActivity());
		builder.setItems(_imageName, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int whichButton) {
				// 각 리스트를 선택했을때				
				
				_context.dispatchStatusEventAsync("selectImage", _imageName[whichButton]);
			}
		});
		builder.show();
		return null;
	}

	
}