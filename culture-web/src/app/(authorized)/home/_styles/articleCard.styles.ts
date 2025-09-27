export const articleCardStyles =
  {
    card: {
      cursor:
        "pointer" as const,
      transition:
        "transform 0.2s, box-shadow 0.2s",
    },
    cardDefault:
      {
        cursor:
          "default" as const,
        transition:
          "transform 0.2s, box-shadow 0.2s",
      },
    cardHover:
      {
        transform:
          "translateY(-2px)",
        boxShadow:
          "0 4px 12px rgba(0, 0, 0, 0.15)",
      },
    cardLeave:
      {
        transform:
          "translateY(0)",
        boxShadow:
          "",
      },
    imageContainer:
      {
        borderRadius:
          "8px",
        overflow:
          "hidden" as const,
        flexShrink: 0,
        width:
          "200px",
        height:
          "120px",
      },
    image:
      {
        width:
          "100%",
        height:
          "100%",
        objectFit:
          "cover" as const,
      },
    contentContainer:
      {
        flex: 1,
        minWidth: 0,
      },
    excerptText:
      {
        lineHeight:
          "1.6",
        display:
          "-webkit-box" as const,
        WebkitLineClamp: 2,
        WebkitBoxOrient:
          "vertical" as const,
        overflow:
          "hidden" as const,
      },
    authorText:
      {
        flexShrink: 0,
      },
    headingText:
      {
        lineHeight:
          "1.4",
      },
  };
