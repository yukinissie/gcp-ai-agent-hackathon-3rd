export const chatBotStyles = {
    container: {
        position: 'fixed' as const,
        bottom: '20px',
        right: '20px',
        zIndex: 1000,
    },
    card: {
        width: '350px',
        height: '400px',
        marginBottom: '10px',
        display: 'flex' as const,
        flexDirection: 'column' as const,
        boxShadow: '0 10px 25px rgba(0, 0, 0, 0.15)',
    },
    messageArea: {
        flex: 1,
        display: 'flex' as const,
        alignItems: 'center' as const,
        justifyContent: 'center' as const,
    },
    messageBox: {
        maxWidth: '80%',
        padding: '12px 16px',
        borderRadius: '12px',
        backgroundColor: 'var(--gray-3)',
        color: 'var(--gray-12)',
        textAlign: 'center' as const,
    },
    messageText: {
        lineHeight: '1.4'
    },
    inputArea: {
        borderTop: '1px solid var(--gray-6)',
        backgroundColor: 'var(--gray-1)',
        borderRadius: '0 0 12px 12px',
    },
    robotIcon: {
        width: '60px',
        height: '60px',
        borderRadius: '50%',
        background: 'linear-gradient(135deg, #ff6b6b, #ffd93d)',
        display: 'flex' as const,
        alignItems: 'center' as const,
        justifyContent: 'center' as const,
        boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
        fontSize: '24px',
        marginLeft: 'auto' as const,
    }
};
