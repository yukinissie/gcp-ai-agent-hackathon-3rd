export const chatInputStyles = {
    form: {
        width: '100%',
    },
    textField: {
        flex: 1,
        padding: '8px 12px',
        border: '1px solid var(--gray-6)',
        borderRadius: '8px',
        fontSize: '14px',
        outline: 'none',
        backgroundColor: 'var(--gray-1)',
        color: 'var(--gray-12)',
        // スマホでの入力体験を向上
        minHeight: '40px',
    },
} as const;
