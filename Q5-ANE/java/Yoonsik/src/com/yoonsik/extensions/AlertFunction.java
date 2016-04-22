package com.yoonsik.extensions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
//import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
//import com.adobe.fre.FRETypeMismatchException;
//import com.adobe.fre.FREWrongThreadException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;

public class AlertFunction implements FREFunction {
	private Activity activity;

	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		activity = arg0.getActivity();
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
		DialogSimple();
		return null;
	}

	public void DialogSimple() {
		AlertDialog.Builder alt_bld = new AlertDialog.Builder(activity);
		alt_bld.setMessage("Do you want to close this window ?").setCancelable(false)
				.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						// Action for 'Yes' Button
						activity.onBackPressed();
					}
				}).setNegativeButton("No", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int id) {
						// Action for 'NO' Button
						dialog.cancel();
					}
				});
		AlertDialog alert = alt_bld.create();
		// Title for AlertDialog
		alert.setTitle("Á¾·á");
		// Icon for AlertDialog
		// alert.setIcon(R.drawable.icon);
		alert.show();
	}
}
