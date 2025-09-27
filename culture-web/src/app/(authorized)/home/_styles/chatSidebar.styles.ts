export const chatSidebarStyles =
  {
    container:
      {
        height:
          "100vh",
        display:
          "flex" as const,
        flexDirection:
          "column" as const,
        backgroundColor:
          "var(--gray-1)",
        borderLeft:
          "1px solid var(--gray-6)",
        width:
          "400px",
        minWidth:
          "350px",
      },
    header:
      {
        borderBottom:
          "1px solid var(--gray-6)",
        backgroundColor:
          "var(--gray-2)",
        height:
          "40px",
        minHeight:
          "40px",
      },
    closeButton:
      {
        cursor:
          "pointer" as const,
        color:
          "var(--gray-11)",
        width:
          "24px",
        height:
          "24px",
      },
    messagesContainer:
      {
        flex: 1,
        position:
          "relative" as const,
        minHeight: 0,
        // スマホでのスクロール改善
        overflowY:
          "auto" as const,
      },
    scrollArea:
      {
        height:
          "100%",
        width:
          "100%",
      },
    avatarBox:
      {
        width:
          "24px",
        height:
          "24px",
        borderRadius:
          "50%",
        backgroundColor:
          "var(--accent-9)",
        display:
          "flex" as const,
        alignItems:
          "center" as const,
        justifyContent:
          "center" as const,
        fontSize:
          "12px",
        overflow:
          "hidden" as const,
      },
    avatarImage:
      {
        width:
          "100%",
        height:
          "100%",
        objectFit:
          "cover" as const,
        display:
          "block" as const,
      },
    messageBox:
      {
        maxWidth:
          "80%",
        padding:
          "8px 12px",
        borderRadius:
          "12px",
        backgroundColor:
          "var(--gray-3)",
        color:
          "var(--gray-12)",
        wordBreak:
          "break-word" as const,
        fontSize:
          "14px",
        lineHeight:
          "1.4",
      },
    messageBoxUser:
      {
        maxWidth:
          "80%",
        padding:
          "8px 12px",
        borderRadius:
          "12px",
        backgroundColor:
          "#e3f2fd",
        color:
          "var(--gray-12)",
        wordBreak:
          "break-word" as const,
        fontSize:
          "14px",
        lineHeight:
          "1.4",
      },
    messageText:
      {
        lineHeight:
          "1.4",
      },
    messageTextTeal:
      {
        lineHeight:
          "1.4",
        color:
          "var(--teal-9)",
      },
    timestamp:
      {
        color:
          "var(--teal-9)",
      },
    inputArea:
      {
        borderTop:
          "1px solid var(--gray-6)",
        backgroundColor:
          "var(--gray-2)",
        minHeight:
          "70px",
        // スマホでの入力エリア固定表示
        position:
          "sticky" as const,
        bottom: 0,
        zIndex: 10,
        // スマホでのキーボード対応
        paddingBottom:
          "env(safe-area-inset-bottom)",
      },
  };
