export const homeStyles = {
    mainContainer: {
        height: '100vh'
    },
    // base/main content (no dynamic marginRight here)
    mainContent: {
        flex: 1,
        overflow: 'auto' as const,
        transition: 'margin-right 0.3s ease',
    },
    // helper to compute mainContent when chat is open/closed
    getMainContent: (isChatOpen: boolean) => ({
        flex: '1',
        marginRight: isChatOpen ? '400px' : '0px',
        overflowX: 'auto' as const,
        overflowY: 'auto' as const,
        transitionProperty: 'margin-right',
        transitionDuration: '0.3s',
        transitionTimingFunction: 'ease',
        transitionDelay: '0s',
        transitionBehavior: 'normal',
        position: 'relative' as const,
        flexGrow: '1',
        flexShrink: '1',
        flexBasis: '0%',
    }),
    // logout box position inside mainContent to avoid overlap with chat
    logoutBox: {
        position: 'absolute' as const,
        top: 16,
        right: 16,
        zIndex: 40,
    },
    chatSidebar: {
        position: 'fixed' as const,
        right: 0,
        top: 0,
        height: '100vh',
        width: '400px',
        transition: 'transform 0.3s ease',
        zIndex: 1000,
    },
    reopenChatButton: {
        position: 'fixed' as const,
        bottom: '20px',
        right: '20px',
        width: '60px',
        height: '60px',
        borderRadius: '50%',
        overflow: 'hidden' as const,
        background: 'linear-gradient(135deg, #ff6b6b, #ffd93d)',
        display: 'flex' as const,
        alignItems: 'center' as const,
        justifyContent: 'center' as const,
        cursor: 'pointer' as const,
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
        transition: 'transform 0.2s, box-shadow 0.2s',
        fontSize: '24px',
        zIndex: 1001,
    },
    reopenImageWrapper: {
        position: 'relative' as const,
        width: '100%',
        height: '100%',
        overflow: 'hidden' as const,
        borderRadius: '50%'
    },
    reopenImage: {
        objectFit: 'cover' as const,
        background: 'transparent',
        WebkitTapHighlightColor: 'transparent',
        outline: 'none',
        display: 'block' as const,
    },
    reopenButtonHover: {
        transform: 'scale(1.1)',
        boxShadow: '0 6px 16px rgba(0, 0, 0, 0.2)',
    },
    reopenButtonLeave: {
        transform: 'scale(1)',
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
    }
};
