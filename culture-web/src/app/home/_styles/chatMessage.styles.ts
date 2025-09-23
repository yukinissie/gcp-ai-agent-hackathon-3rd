export const chatMessageStyles = {
    container: {
        width: '100%',
    },
    avatarBox: {
        width: '24px',
        height: '24px',
        borderRadius: '50%',
        backgroundColor: 'var(--accent-9)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: '12px',
    },
    messageBox: (isUser: boolean) => ({
        maxWidth: '80%',
        padding: '8px 12px',
        borderRadius: '12px',
        backgroundColor: isUser
            ? 'var(--accent-9)'
            : 'var(--gray-3)',
        color: isUser
            ? 'var(--accent-contrast)'
            : 'var(--gray-12)',
        wordBreak: 'break-word' as const,
    }),
    messageText: {
        lineHeight: '1.4',
    },
} as const;
