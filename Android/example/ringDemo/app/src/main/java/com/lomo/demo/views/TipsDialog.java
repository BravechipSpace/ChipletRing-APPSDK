package com.lomo.demo.views;

import android.app.Dialog;
import android.content.Context;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.lomo.demo.R;


public class TipsDialog extends Dialog {
    private TextView view_dialog_cancel;
    private TextView view_dialog_commit;
    private  TextView view_dialog_title;
    private  TextView view_dialog_msg;

    public TipsDialog(@NonNull Context context) {
        super(context, R.style.style_loading_dialog);
        setContentView(R.layout.dialog_tips);
        view_dialog_title =findViewById(R.id.view_dialog_title);
        view_dialog_msg=findViewById(R.id.view_dialog_msg);
        view_dialog_commit= findViewById(R.id.view_dialog_commit);
        view_dialog_cancel= findViewById(R.id.view_dialog_cancel);
        view_dialog_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dismiss();
            }
        });

    }

    public TipsDialog setDialogTitle(int titleId) {
        view_dialog_title.setText(titleId);
        return this;
    }
    public TipsDialog setDialogMsg(int msgId) {
        view_dialog_msg.setText(msgId);
        return this;
    }
    public TipsDialog setDialogMsg(String msgId) {
        view_dialog_msg.setText(msgId);
        return this;
    }
    public TipsDialog setCommitClickListener(View.OnClickListener onClickListener) {
        view_dialog_commit.setOnClickListener(onClickListener);
        return this;
    }
    public TipsDialog setCommitClickListener(int txtId,View.OnClickListener onClickListener) {
        view_dialog_commit.setText(txtId);
        view_dialog_commit.setOnClickListener(onClickListener);
        return this;
    }
    public TipsDialog setCommitClickListener(String text,View.OnClickListener onClickListener) {
        view_dialog_commit.setText(text);
        view_dialog_commit.setOnClickListener(onClickListener);
        return this;
    }
    public TipsDialog setCancelClickListener(View.OnClickListener onClickListener) {
        view_dialog_cancel.setOnClickListener(onClickListener);
        return this;
    }
    public TipsDialog setCancelClickListener(int txtId,View.OnClickListener onClickListener) {
        view_dialog_cancel.setText(txtId);
        view_dialog_cancel.setOnClickListener(onClickListener);
        return this;
    }
}
