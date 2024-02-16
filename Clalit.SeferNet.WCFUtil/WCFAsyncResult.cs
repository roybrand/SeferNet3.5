using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace Clalit.SeferNet.WCFUtil
{
    /// <summary>
    /// this class is used to return the result of an asyncronized action of wcf service
    /// </summary>
    public class WCFAsyncResult : IAsyncResult, IDisposable
    {
        private AsyncCallback m_AsyncCallback;
        private object m_State;
        private ManualResetEvent m_ManualResetEvent;

        /// <summary>
        /// Initializes a new instance of the <see cref="AsyncResult"/> class.
        /// </summary>
        /// <param name="callback">The callback.</param>
        /// <param name="state">The state.</param>
        public WCFAsyncResult(
            AsyncCallback callback,
            object state)
        {
            this.m_AsyncCallback = callback;
            this.m_State = state;
            this.m_ManualResetEvent = new ManualResetEvent(false);
        }

        /// <summary>
        /// Completes this instance.
        /// </summary>
        public virtual void OnCompleted()
        {
            m_ManualResetEvent.Set();
            if (m_AsyncCallback != null)
            {
                m_AsyncCallback(this);
            }
        }

        #region IAsyncResult Members
        /// <summary>
        /// Gets a user-defined object that qualifies or contains information about an asynchronous operation.
        /// </summary>
        /// <value></value>
        /// <returns>A user-defined object that qualifies or contains information about an asynchronous operation.</returns>
        public object AsyncState
        {
            get
            {
                return m_State;
            }
        }

        /// <summary>
        /// Gets a <see cref="T:System.Threading.WaitHandle"/> that is used to wait for an asynchronous operation to complete.
        /// </summary>
        /// <value></value>
        /// <returns>A <see cref="T:System.Threading.WaitHandle"/> that is used to wait for an asynchronous operation to complete.</returns>
        public System.Threading.WaitHandle AsyncWaitHandle
        {
            get
            {
                return m_ManualResetEvent;
            }
        }

        /// <summary>
        /// Gets an indication of whether the asynchronous operation completed synchronously.
        /// </summary>
        /// <value></value>
        /// <returns>true if the asynchronous operation completed synchronously; otherwise, false.</returns>
        public bool CompletedSynchronously
        {
            get
            {
                return false;
            }
        }

        /// <summary>
        /// Gets an indication whether the asynchronous operation has completed.
        /// </summary>
        /// <value></value>
        /// <returns>true if the operation is complete; otherwise, false.</returns>
        public bool IsCompleted
        {
            get
            {
                return m_ManualResetEvent.WaitOne(0, false);
            }
        }
        #endregion IAsyncResult Members

        #region IDisposable Members
        private bool m_IsDisposed = false;
        private event System.EventHandler m_Disposed;

        /// <summary>
        /// Gets a value indicating whether this instance is disposed.
        /// </summary>
        /// <value>
        ///     <c>true</c> if this instance is disposed; otherwise, <c>false</c>.
        /// </value>
        [System.ComponentModel.Browsable(false)]
        public bool IsDisposed
        {
            get
            {
                return m_IsDisposed;
            }
        }

        /// <summary>
        /// Occurs when this instance is disposed.
        /// </summary>
        public event System.EventHandler Disposed
        {
            add
            {
                m_Disposed += value;
            }
            remove
            {
                m_Disposed -= value;
            }
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        public void Dispose()
        {
            if (!m_IsDisposed)
            {
                this.Dispose(true);
                System.GC.SuppressFinalize(this);
            }
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (disposing)
                {
                    this.m_ManualResetEvent.Close();
                    this.m_ManualResetEvent = null;
                    m_State = null;
                    m_AsyncCallback = null;

                    System.EventHandler handler = m_Disposed;
                    if (handler != null)
                    {
                        handler(this, System.EventArgs.Empty);
                        handler = null;
                    }
                }
            }
            finally
            {
                m_IsDisposed = true;
            }
        }

        /// <summary>
        ///    <para>
        ///        Checks if the instance has been disposed of, and if it has, throws an <see cref="ObjectDisposedException"/>; otherwise, does nothing.
        ///    </para>
        /// </summary>
        /// <exception cref="System.ObjectDisposedException">
        ///    The instance has been disposed of.
        ///    </exception>
        ///    <remarks>
        ///    <para>
        ///        Derived classes should call this method at the start of all methods and properties that should not be accessed after a call to <see cref="Dispose()"/>.
        ///    </para>
        /// </remarks>
        protected void CheckDisposed()
        {
            if (m_IsDisposed)
            {
                string typeName = GetType().FullName;

                // TODO: You might want to move the message string into a resource file
                throw new System.ObjectDisposedException(
                    typeName,
                    String.Format(System.Globalization.CultureInfo.InvariantCulture,
                        "Cannot access a disposed {0}.",
                        typeName));
            }
        }
        #endregion IDisposable Members
    }

}
