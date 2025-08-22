package com.lomo.demo.nfc.generic.util.async;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

    public abstract class AdvancedAsyncTask<INPUT, PROGRESS, OUTPUT> {
        public static final String TAG = "AsyncTaskRunner";

        private static final Executor THREAD_POOL_EXECUTOR =
                new ThreadPoolExecutor(1, 1, 1000,
                        TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());

        private final Handler mHandler = new Handler(Looper.getMainLooper());

        private final AtomicBoolean mIsInterrupted = new AtomicBoolean(false);

        protected void onPreExecute(){}
        protected abstract OUTPUT doInBackground(INPUT input) throws Exception;

        protected void onPostExecute(OUTPUT output) {}

        protected void onCancelled(){}

        protected abstract void onBackgroundError(Exception e);

        public AdvancedAsyncTask<INPUT, PROGRESS, OUTPUT> execute() {
            return execute(null);
        }

        public final AdvancedAsyncTask<INPUT, PROGRESS, OUTPUT> execute(final INPUT input) {
            THREAD_POOL_EXECUTOR.execute(() -> {
                try {
                    checkInterrupted();
                    mHandler.post(this::onPreExecute);

                    checkInterrupted();
                    final OUTPUT output = doInBackground(input);

                    checkInterrupted();
                    mHandler.post(() -> onPostExecute(output));
                } catch (InterruptedException ex) {
                    mHandler.post(this::onCancelled);
                } catch (Exception ex) {
                    Log.e(TAG, "executeAsync: " + ex.getMessage() + "\n" + ex.getStackTrace());
                }
            });
            return this;
        }

        public void cancel(boolean mayInterruptIfRunning){
            setInterrupted(mayInterruptIfRunning);
        }

        public boolean isCancelled(){
            return isInterrupted();
        }

        protected void checkInterrupted() throws InterruptedException {
            if (isInterrupted()){
                throw new InterruptedException();
            }
        }

        protected boolean isInterrupted() {
            return mIsInterrupted.get();
        }

        protected void setInterrupted(boolean interrupted) {
            mIsInterrupted.set(interrupted);
        }
    }