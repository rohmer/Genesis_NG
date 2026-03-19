using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Core;
using log4net.Repository.Hierarchy;

using Seq.Client.Log4Net;

using System;
using System.Diagnostics;

using UnityEngine;

using System.Threading.Tasks;


namespace AhahGames.Telemetry
{
    public class TelemetryLogger 
    {
        private static TelemetryLogger instance;        
        private string uniqueID = SystemInfo.deviceUniqueIdentifier;
        private static Hierarchy hierarchy = null;
        private ILog logger;
        private static Guid sessionID= Guid.NewGuid();
        public static TelemetryLogger Logger { 
            get 
            {
                if (instance == null)
                    instance = new TelemetryLogger();
                return instance; 
            } 
        }

        private static IAppender CreateSeqAppender()
        {
#if GENESIS_TELEMETRY
            SeqAppender appender = new SeqAppender();
            appender.ApiKey = "eIvH3GJDlnOpUDuXffHU";
            appender.ServerUrl = "http://localhost:5341";
            appender.BufferSize = 1;
#if GENESIS_DEBUG
            appender.Threshold = Level.All;
#else
            appender.Threshold = Level.Notice
#endif
            appender.ActivateOptions();
            return appender;
#endif
            return null;
        }

        private static IAppender CreateUnityAppender()
        {
            UnityAppender ua = new UnityAppender();
            var h = (Hierarchy)LogManager.GetRepository();
#if GENESIS_DEBUG
            ua.Threshold = Level.All;
#else
            ua.Threshold=Level.Notice;
#endif

            ua.Layout = new log4net.Layout.PatternLayout();
            ua.ActivateOptions();
            return ua;
        }

        public TelemetryLogger()
        {
#if GENESIS_TELEMETRY
            BasicConfigurator.Configure();
            logger = LogManager.GetLogger("Genesis Noise");

            log4net.Repository.Hierarchy.Logger l = (log4net.Repository.Hierarchy.Logger)logger.Logger;
            l.AddAppender(CreateSeqAppender());
           //Application.logMessageReceived += telemetryLog;

            l.AddAppender(CreateUnityAppender());
#endif
        }

        public void LogException(Exception e)
        {
            string msg = string.Format("{0}|{1}|{2}", uniqueID, "Exception", e.Message);
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Fatal(msg, e));
        }

        public string stackTraceToJSON(string stackTrace)
        {
            string msg = "{\"stackTrace\":[";
            foreach(var line in stackTrace.Split(new char[] { '\n' }))
            {
                msg += "\"" + line + "\",";
            }
            msg += "]}";
            return msg;
        }

        public void LogException(string eMsg, string stackTrace)
        {
            string msg = string.Format("{0}|{1}|{2}|{3}", uniqueID, "Exception", eMsg, stackTraceToJSON(stackTrace));
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Fatal(msg));
        }

        public void LogError(string Msg)
        {
            string msg = string.Format("{0}|{1}|{2}", uniqueID, "Error", Msg);
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Error(msg));
        }

        public void LogError(string eMsg, string stackTrace)
        {
            string msg = string.Format("{0}|{1}|{2}|{3}", uniqueID, "Error", eMsg, stackTraceToJSON(stackTrace));
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Error(msg));
        }

        public void LogWarn(string Msg)
        {
            string msg = string.Format("{0}|{1}|{2}", uniqueID, "Warn", Msg);
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Warn(msg));
        }

        public void LogWarn(string eMsg, string stackTrace)
        {
            string msg = string.Format("{0}|{1}|{2}|{3}", uniqueID, "Warn", eMsg, stackTraceToJSON(stackTrace));
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Warn(msg));
        }

        public void LogInfo(string Msg)
        {
            string msg = string.Format("{0}|{1}|{2}", uniqueID, "Info", Msg);
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Info(msg));
        }

        public void LogInfo(string eMsg, string stackTrace)
        {
            string msg = string.Format("{0}|{1}|{2}|{3}", uniqueID, "Info", eMsg, stackTraceToJSON(stackTrace));
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Info(msg));
        }
        public void LogTelemetry(string action, string typeForAction)
        {
            string msg = "{\"action\":\"" + action + "\",";
            msg += "\"actionType\":\"" + typeForAction + "\",";
            msg += "\"uniqueID:\"" + uniqueID + "\"}";
            Task.Run(() => LogManager.GetLogger("Genesis Noise").Debug(msg));
        }

        private string JSONLogfile(string path)
        {
            string input = System.IO.File.ReadAllText(path);

            string output = "{[";
            foreach (string line in input.Split(new char[] { '\r', '\n' }))
            {
                output += String.Format("\"{0}\",", line);
            }
            output += "]}";
            return output;
        }
         
        public void LogMachineInfo()
        {
            string buildType = Application.buildGUID;
            string platform = Application.platform.ToString();
            string sessID = sessionID.ToString();
            string buildID = Application.version;
            string unityVersion = Application.unityVersion;
            string genuine = Application.genuine.ToString();
            Process proc = Process.GetCurrentProcess();
            string msg = "{\n\"telemetry\":\"" + uniqueID + "\",\n";
            msg += "\"sessionID\":\"" + sessID + "\",\n";
            msg += "\"buildType\":\"" + buildType + "\",\n";
            msg += "\"platform\":\"" + platform + "\",\n";
            msg += "\"buildID\":\"" + buildID + "\",\n";
            msg += "\"genuine\":\"" + genuine + "\",\n";
            msg += "\"unityVersion\":\"" + unityVersion + "\"}\n";

            Task.Run(() => LogManager.GetLogger("Genesis Noise").Info(msg));            
        }

        void telemetryLog(string logString, string stackTrace, LogType type)
        {
            switch(type)
            {
                case LogType.Error:
                    LogError(logString, stackTrace);
                    break;
                case LogType.Warning:
                    LogWarn(logString, stackTrace);
                    break;
                case LogType.Exception:
                    LogException(logString, stackTrace);
                    break;
                case LogType: Info:
                    LogInfo(logString, stackTrace);
                    break;
             
            }
        }
    }
}
