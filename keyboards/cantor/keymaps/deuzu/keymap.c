#include QMK_KEYBOARD_H
#include "keymap_us_international.h"

#define KC_COPY LCTL(KC_C)
#define KC_CUT LCTL(KC_X)
#define KC_PSTE LCTL(KC_V)
#define KC_SAVE LCTL(KC_S)
#define KC_UNDO LCTL(KC_Z)
#define KC_AGIN RCS(KC_Z)
#define KC_FIND LCTL(KC_F)
#define KC_SELA LCTL(KC_A)

enum layers {
    _ISRT,
    _NAV,
    _NUM,
    _FUN,
    _SYM,
    _FK,
    _GAM,
    _GAM2,
    _QWER,
};

enum custom_keycodes {
    UPDIR = SAFE_RANGE,
    // UD_* (undead): deadkeys transformed into a normal keys by appending a KC_SPACE
    UD_QUOT,
    UD_DQUO,
    UD_CIRC,
    UD_GRV,
    UD_TILD,
};

const uint16_t PROGMEM gaming_on[] = { KC_M, KC_K, COMBO_END };
const uint16_t PROGMEM gaming_off[] = { KC_C, KC_V, COMBO_END };
const uint16_t PROGMEM qwerty_on[] = { KC_D, KC_J, COMBO_END };
const uint16_t PROGMEM qwerty_off[] = { KC_V, KC_B, COMBO_END };

combo_t key_combos[COMBO_COUNT] = {
  COMBO(gaming_on, TO(_GAM)),
  COMBO(gaming_off, TO(_ISRT)),
  COMBO(qwerty_on, TO(_QWER)),
  COMBO(qwerty_off, TO(_ISRT)),
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /*
     * ISRT LAYOUT
     *
     * activate GAMING by pressing M + K
     * activate QWERTY by pressing D + J
     *
     *                ┌────────┬────────┬────────┬────────┬────────┬────────┐                ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *                │ ^      │ Y      │ C      │ L      │ M      │ K      │                │ Z      │ F      │ U      │ , <    │ ' "    │ - _    │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │ ´      │ Gui(I) │ Alt(S) │ Sft(R) │ Ctl(T) │ G      │                │ P      │ Ctl(N) │ Sft(E) │ Alt(A) │ Gui(O) │ ; :    │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │ `      │ Q      │ V      │ W      │ D      │ J      │                │ B      │ H      │ / ?    │ . >    │ X      │ ¨      │
     *                └────────┴────────┴────────┴────────┴────────┴────────┘                └────────┴────────┴────────┴────────┴────────┴────────┘
     *                               ┌────────────┐                                                                    ┌────────────┐
     *                               │Lt(FK, Esc) ├────────────┐                                          ┌────────────┤Lt(XXX, Del)│
     *                               └────────────┤Lt(FUN, Bsp)├────────────┐                ┌────────────┤Lt(SYM, Tab)├────────────┘
     *                                            └────────────┤Lt(NAV, Spc)│                │Lt(NUM, Ent)├────────────┘
     *                                                         └────────────┘                └────────────┘
     */
    [_ISRT] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        US_DCIR, KC_Y,         KC_C,         KC_L,         KC_M,         KC_K,               KC_Z, KC_F,         KC_U,         KC_COMMA,     UD_QUOT,      KC_MINS,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        US_ACUT, LGUI_T(KC_I), LALT_T(KC_S), LSFT_T(KC_R), LCTL_T(KC_T), KC_G,               KC_P, RCTL_T(KC_N), RSFT_T(KC_E), RALT_T(KC_A), RGUI_T(KC_O), KC_SCLN,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        US_DGRV, KC_Q,         KC_V,         KC_W,         KC_D,         KC_J,               KC_B, KC_H,         KC_SLSH,      KC_DOT,       KC_X,         US_DIAE,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
                         LT(_FK, KC_ESC), LT(_FUN, KC_BSPC), LT(_NAV, KC_SPC),               LT(_NUM, KC_ENT), LT(_SYM, KC_TAB), LT(XXXXXXX, KC_DEL)
    ),

    /*
     * NAVIGATION LAYOUT
     *
     *                ┌────────┬────────┬────────┬────────┬────────┬────────┐                ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *                │        │        │        │        │        │        │                │        │ Home   │ PgDn   │ PgUp   │ End    │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │ Gui    │ Alt    │ Sft    │ Ctl    │        │                │        │ ←      │ ↓      │ ↑      │ →      │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │        │        │        │        │        │                │        │        │        │        │        │        │
     *                └────────┴────────┴────────┴────────┴────────┴────────┘                └────────┴────────┴────────┴────────┴────────┴────────┘
     *                               ┌────────────┐                                                                    ┌────────────┐
     *                               │            ├────────────┐                                          ┌────────────┤ Del        │
     *                               └────────────┤            ├────────────┐                ┌────────────┤ Tab        ├────────────┘
     *                                            └────────────┤ ********** │                │ Ent        ├────────────┘
     *                                                         └────────────┘                └────────────┘
     */
    [_NAV] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,     XXXXXXX,                XXXXXXX,    KC_HOME,    KC_PGDN,    KC_PGUP,    KC_END,     XXXXXXX,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        XXXXXXX,    KC_LGUI,    KC_LALT,    KC_LSFT,    KC_LCTL,     XXXXXXX,                XXXXXXX,    KC_LEFT,    KC_DOWN,    KC_UP,      KC_RGHT,    XXXXXXX,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
        XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,     XXXXXXX,                XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------                -------------------------------------------------------------------//
                                            XXXXXXX,    XXXXXXX,     XXXXXXX,                KC_ENT,     KC_TAB,     KC_DEL
    ),

    /*
     * NUMERIC LAYOUT
     *
     *                ┌────────┬────────┬────────┬────────┬────────┬────────┐                ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *                │        │        │        │        │ -      │        │                │        │ +      │ =      │ ,      │        │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │ 1      │ 2      │ 3      │ 4      │ 5      │                │ 6      │ 7      │ 8      │ 9      │ 0      │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │        │        │        │ /      │        │                │        │ *      │        │ .      │        │        │
     *                └────────┴────────┴────────┴────────┴────────┴────────┘                └────────┴────────┴────────┴────────┴────────┴────────┘
     *                               ┌────────────┐                                                                    ┌────────────┐
     *                               │ Esc        ├────────────┐                                          ┌────────────┤            │
     *                               └────────────┤ Bspc       ├────────────┐                ┌────────────┤            ├────────────┘
     *                                            └────────────┤ Spc        │                │ ********** ├────────────┘
     *                                                         └────────────┘                └────────────┘
     */
    [_NUM] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    KC_MINS,     XXXXXXX,                 XXXXXXX,    KC_PLUS,    KC_EQL,    KC_COMMA,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    KC_1,       KC_2,       KC_3,       KC_4,        KC_5,                    KC_6,       KC_7,       KC_8,       KC_9,       KC_0,       XXXXXXX,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    KC_SLSH,     XXXXXXX,                 XXXXXXX,    KC_ASTR,    XXXXXXX,    KC_DOT,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
                                            KC_ESC,     KC_BSPC,     KC_SPC,                  XXXXXXX,    XXXXXXX,    XXXXXXX
    ),

    /*
     * FUNCTION LAYOUT
     *
     *               ┌────────┬────────┬────────┬────────┬────────┬────────┐              ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *               │ Next T │ Vol Up │ Sel. A │ Undo   │ Cut    │        │              │        │        │        │        |        │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ PlayPa │ Mute   │ Find   │ Save   │ Copy   │ Pr.Scr │              │        │ Ctl    │ Sft    │ Alt    │ Gui    │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ Prev T │ Vol D  │        │ Redo   │ Paste  │        │              │        │        │        │        │        │        │
     *               └────────┴────────┴────────┴────────┴────────┴────────┘              └────────┴────────┴────────┴────────┴────────┴────────┘
     *                              ┌────────────┐                                                                  ┌────────────┐
     *                              │            ├────────────┐                                        ┌────────────┤ Del        │
     *                              └────────────┤ ********** ├────────────┐              ┌────────────┤ Tab        ├────────────┘
     *                                           └────────────┤            │              │ Ent        ├────────────┘
     *                                                        └────────────┘              └────────────┘
     */
    [_FUN] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         KC_MNXT,    KC_VOLU,    KC_SELA,   KC_UNDO,     KC_CUT,      XXXXXXX,              XXXXXXX,    XXXXXXX,   XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         KC_MPLY,    KC_MUTE,    KC_FIND,   KC_SAVE,     KC_COPY,     KC_PSCR,              XXXXXXX,    KC_LCTL,   KC_LSFT,    KC_LALT,    KC_LGUI,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         KC_MPRV,    KC_VOLD,    XXXXXXX,   KC_AGIN,     KC_PSTE,     XXXXXXX,              XXXXXXX,    XXXXXXX,   XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
                                            XXXXXXX,     XXXXXXX,     XXXXXXX,              KC_ENT,     KC_TAB,    KC_DEL
    ),

    /*
     * SYMBOL LAYOUT
     *
     *                ┌────────┬────────┬────────┬────────┬────────┬────────┐                ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *                │        │ '      │ <      │ >      │ "      │ .      │                │ &      │ ../    │ [      │ ]      │ %      │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │ !      │ -      │ +      │ =      │ #      │                │ |      │ :      │ (      │ )      │ ?      │        │
     *                ├────────┼────────┼────────┼────────┼────────┼────────┤                ├────────┼────────┼────────┼────────┼────────┼────────┤
     *                │        │ ^      │ /      │ *      │ \      │ `      │                │ ~      │ $      │ {      │ }      │ @      │ €      │
     *                └────────┴────────┴────────┴────────┴────────┴────────┘                └────────┴────────┴────────┴────────┴────────┴────────┘
     *                               ┌────────────┐                                                                    ┌────────────┐
     *                               │ Esc        ├────────────┐                                          ┌────────────┤            │
     *                               └────────────┤ Bspc       ├────────────┐                ┌────────────┤ ********** ├────────────┘
     *                                            └────────────┤ Spc        │                │            ├────────────┘
     *                                                         └────────────┘                └────────────┘
     */
    [_SYM] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    UD_QUOT,    KC_LABK,    KC_RABK,    UD_DQUO,    KC_DOT,                   KC_AMPR,    UPDIR,      KC_LBRC,    KC_RBRC,    KC_PERC,    XXXXXXX,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    KC_EXLM,    KC_MINS,    KC_PLUS,    KC_EQL,     KC_HASH,                  KC_PIPE,    KC_SCLN,    KC_LPRN,    KC_RPRN,    KC_QUES,    XXXXXXX,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
        XXXXXXX,    UD_CIRC,    KC_SLSH,    KC_ASTR,    KC_BSLS,    UD_GRV,                   UD_TILD,    KC_DLR,     KC_LCBR,    KC_RCBR,    KC_AT,      US_EURO,
        //-------------------------------------------------------------------                 -------------------------------------------------------------------//
                                            KC_ESC,     KC_BSPC,    KC_SPC,                   XXXXXXX,    XXXXXXX,    XXXXXXX
    ),

    /*
     * FKEYS LAYOUT
     *
     *               ┌────────┬────────┬────────┬────────┬────────┬────────┐              ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *               │        │        │        │        │        │        │              │        │ F9     │ F10    │ F11    | F12    │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │        │ Gui    │ Alt    │ Sft    │ Ctl    │        │              │        │ F5     │ F6     │ F7     │ F8     │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │        │        │        │        │        │        │              │        │ F1     │ F2     │ F3     │ F4     │        │
     *               └────────┴────────┴────────┴────────┴────────┴────────┘              └────────┴────────┴────────┴────────┴────────┴────────┘
     *                              ┌────────────┐                                                                  ┌────────────┐
     *                              │ ********** ├────────────┐                                        ┌────────────┤ Del        │
     *                              └────────────┤            ├────────────┐              ┌────────────┤ Tab        ├────────────┘
     *                                           └────────────┤            │              │ Ent        ├────────────┘
     *                                                        └────────────┘              └────────────┘
     */
    [_FK] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,              XXXXXXX,     KC_F9,     KC_F10,     KC_F11,     KC_F12,     XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         XXXXXXX,    KC_LGUI,    KC_LALT,    KC_LSFT,    KC_LCTL,    XXXXXXX,              XXXXXXX,     KC_F5,     KC_F6,      KC_F7,      KC_F8,      XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
         XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,              XXXXXXX,     KC_F1,     KC_F2,      KC_F3,      KC_F4,      XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
                                              XXXXXXX,    XXXXXXX,   XXXXXXX,              KC_ENT,      KC_TAB,    KC_DEL
    ),

    /*
     * GAMING 1 LAYOUT
     *
     * activate ISRT by pressing C + V
     *
     *               ┌────────┬────────┬────────┬────────┬────────┬────────┐              ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *               │ Esc    │ Tab    │ Q      │ W      │ E      │ R      │              │ T      │ Y      │ ↑      │ I      │ O      │ P      │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ Sft    │ Bsp    │ A      │ S      │ D      │ F      │              │ G      │ ←      │ ↓      │ →      │ L      │ U      │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ Ctl    │ Alt    │ Z      │ X      │ C      │ V      │              │ B      │ N      │ M      │ H      │ J      │ K      │
     *               └────────┴────────┴────────┴────────┴────────┴────────┘              └────────┴────────┴────────┴────────┴────────┴────────┘
     *                              ┌────────────┐                                                                  ┌────────────┐
     *                              │ MO(GA2)    ├────────────┐                                        ┌────────────┤            │
     *                              └────────────┤ B          ├────────────┐              ┌────────────┤ P          ├────────────┘
     *                                           └────────────┤ Spc        │              │ Enter      ├────────────┘
     *                                                        └────────────┘              └────────────┘
     */
    [_GAM] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            KC_ESC,     KC_TAB,     KC_Q,       KC_W,       KC_E,        KC_R,             KC_T,       KC_Y,       KC_UP,      KC_I,       KC_O,       KC_P,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            KC_LSFT,    KC_BSPC,    KC_A,       KC_S,       KC_D,        KC_F,             KC_G,       KC_LEFT,    KC_DOWN,    KC_RGHT,    KC_L,       KC_U,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            KC_LCTL,    KC_LALT,    KC_Z,       KC_X,       KC_C,        KC_V,             KC_B,       KC_N,       KC_M,       KC_H,       KC_J,       KC_K,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
                                           MO(_GAM2),       KC_B,      KC_SPC,             KC_ENT,     KC_P,       XXXXXXX
    ),

    /*
     * GAMING 2 LAYOUT
     *
     *               ┌────────┬────────┬────────┬────────┬────────┬────────┐              ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *               │ `      │ 1      │ 2      │ W      │ 3      │ 4      │              │        │        │        │        │        │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ Sft    │ 5      │ A      │ S      │ D      │ 6      │              │        │        │        │        │        │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │ Ctl    │ Alt    │ 7      │ 8      │ 9      │ 0      │              │        │        │        │        │        │        │
     *               └────────┴────────┴────────┴────────┴────────┴────────┘              └────────┴────────┴────────┴────────┴────────┴────────┘
     *                              ┌────────────┐                                                                  ┌────────────┐
     *                              │ ********** ├────────────┐                                        ┌────────────┤            │
     *                              └────────────┤            ├────────────┐              ┌────────────┤            ├────────────┘
     *                                           └────────────┤            │              │            ├────────────┘
     *                                                        └────────────┘              └────────────┘
     */
    [_GAM2] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
        KC_GRV,     KC_1,       KC_2,       _______,    KC_3,           KC_4,              XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
        _______,    KC_5,       _______,    _______,    _______,        KC_6,              XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
        _______,    _______,    KC_7,       KC_8,       KC_9,           KC_0,              XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,    XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
                                            _______,    XXXXXXX,     XXXXXXX,              XXXXXXX,    XXXXXXX,    XXXXXXX
    ),

    /*
     * QWERTY LAYOUT
     *
     * activate ISRT by pressing V + B
     *
     *               ┌────────┬────────┬────────┬────────┬────────┬────────┐              ┌────────┬────────┬────────┬────────┬────────┬────────┐
     *               │        │ Q      │ W      │ E      │ R      │ T      │              │ Y      │ U      │ I      │ O      │ P      │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │        │ A      │ S      │ D      │ F      │ G      │              │ H      │ J      │ K      │ L      │ ' "    │        │
     *               ├────────┼────────┼────────┼────────┼────────┼────────┤              ├────────┼────────┼────────┼────────┼────────┼────────┤
     *               │        │ Z      │ X      │ C      │ V      │ B      │              │ N      │ M      │ , <    │ . >    │ / ?    │        │
     *               └────────┴────────┴────────┴────────┴────────┴────────┘              └────────┴────────┴────────┴────────┴────────┴────────┘
     *                              ┌────────────┐                                                                  ┌────────────┐
     *                              │ Esc        ├────────────┐                                        ┌────────────┤ Del        │
     *                              └────────────┤ Bspc       ├────────────┐              ┌────────────┤ Tab        ├────────────┘
     *                                           └────────────┤ Spc        │              │ Enter      ├────────────┘
     *                                                        └────────────┘              └────────────┘
     */
    [_QWER] = LAYOUT_split_3x6_3(
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            XXXXXXX,    KC_Q,       KC_W,       KC_E,       KC_R,        KC_T,             KC_Y,       KC_U,     KC_I,       KC_O,       KC_P,         XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            XXXXXXX,    KC_A,       KC_S,       KC_D,       KC_F,        KC_G,             KC_H,       KC_J,     KC_K,       KC_L,       UD_QUOT,      XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
            XXXXXXX,    KC_Z,       KC_X,       KC_C,       KC_V,        KC_B,             KC_N,       KC_M,     KC_COMMA,   KC_DOT,     KC_SLSH,      XXXXXXX,
        //-------------------------------------------------------------------              -------------------------------------------------------------------//
                                              KC_ESC,     KC_BSPC,     KC_SPC,             KC_ENT,     KC_TAB,   KC_DEL
    ),
};

bool process_record_user(uint16_t keycode, keyrecord_t* record) {
    switch (keycode) {
        case UPDIR:
            if (record->event.pressed) {
                SEND_STRING("../");
            }

            return false;
        case UD_QUOT:
            if (record->event.pressed) {
                SEND_STRING("' ");
            }

            return false;
        case UD_DQUO:
            if (record->event.pressed) {
                SEND_STRING("\" ");
            }

            return false;
        case UD_CIRC:
            if (record->event.pressed) {
                SEND_STRING("^ ");
            }

            return false;
        case UD_GRV:
            if (record->event.pressed) {
                SEND_STRING("` ");
            }

            return false;
        case UD_TILD:
            if (record->event.pressed) {
                SEND_STRING("~ ");
            }

            return false;
    }

    return true;
}
